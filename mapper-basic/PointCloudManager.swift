import Foundation
import ARKit
import Metal
import MetalKit

// Heavily inspired by https://developer.apple.com/documentation/arkit/visualizing_a_point_cloud_using_scene_depth

class PointCloudManager {
       
    public var pointCloud = PointCloud()
    
    public var viewportSize: CGSize!
    public var orientation: UIInterfaceOrientation!
    
    private var depthMapSize = (x: 256, y: 192)
    private let cameraResolution = (x: 1920, y: 1440)
        
    private let pointCount = 500
    private var frameCounter = 0
    
    private let confidenceThreshold: Float = 1.0
    
    private var grid: [simd_float2] = []
    
    private var pointCloudUniforms = PointCloudUniforms()
    
    private let device: MTLDevice
    private let computePoints: MTLFunction
    private let pipeline: MTLComputePipelineState
    private let commandQueue: MTLCommandQueue
    private let pointCloudUniformsBuffer: MetalBuffer<PointCloudUniforms>
    private let pointUniformsBuffer: MetalBuffer<PointUniforms>
    private lazy var gridPointsBuffer = MetalBuffer<simd_float2>(device: self.device, array: self.gridPoints(), index: kGridPoints.rawValue, options: [])
    private lazy var textureCache = self.makeTextureCache()
    private var capturedImageYTexture: CVMetalTexture?
    private var capturedImageCbCrTexture: CVMetalTexture?
    private var depthTexture: CVMetalTexture?
    private var confidenceTexture: CVMetalTexture?
    
    public init() {
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("Couldn't create MTL device.") }
        self.device = device
        
        guard let computePoints = device.makeDefaultLibrary()?.makeFunction(name: "computePoints") else { fatalError("Couldn't create computePoints function.") }
        self.computePoints = computePoints
        
        guard let pipeline = try? device.makeComputePipelineState(function: computePoints) else { fatalError("Couldn't create pipeline.") }
        self.pipeline = pipeline
    
        guard let commandQueue = self.device.makeCommandQueue() else { fatalError("Couldn't create command queue.") }
        self.commandQueue = commandQueue
        
        self.pointCloudUniformsBuffer = MetalBuffer<PointCloudUniforms>(device: self.device, count: 1, index: kPointCloudUniforms.rawValue)
        self.pointUniformsBuffer = MetalBuffer<PointUniforms>(device: self.device, count: self.pointCount, index: kPointUniforms.rawValue)
        
        self.grid = self.gridPoints()
    }
    
    
    public func update(from frame: ARFrame) {
        guard self.shouldAccumulatePoints() else { return }
        
        let camera = frame.camera
        let cameraIntrinsicsInversed = camera.intrinsics.inverse
        let viewMatrix = camera.viewMatrix(for: self.orientation)
        let viewMatrixInversed = viewMatrix.inverse
        let projectionMatrix = camera.projectionMatrix(for: self.orientation, viewportSize: self.viewportSize, zNear: 0.001, zFar: 0)
        pointCloudUniforms.viewProjectionMatrix = projectionMatrix * viewMatrix
        pointCloudUniforms.localToWorld = viewMatrixInversed * Self.makeRotateToARCameraMatrix(orientation: self.orientation)
        pointCloudUniforms.cameraIntrinsicsInversed = cameraIntrinsicsInversed
        pointCloudUniforms.cameraResolution = simd_float2(1920.0, 1440.0)
        self.pointCloudUniformsBuffer.assign(self.pointCloudUniforms)
        
        if let depthMap = frame.sceneDepth?.depthMap, let confidenceMap = frame.sceneDepth?.confidenceMap {
            
            self.depthTexture = self.makeTexture(fromPixelBuffer: depthMap, pixelFormat: .r32Float, planeIndex: 0)
            self.confidenceTexture = self.makeTexture(fromPixelBuffer: confidenceMap, pixelFormat: .r8Uint, planeIndex: 0)
            self.capturedImageYTexture = self.makeTexture(fromPixelBuffer: frame.capturedImage, pixelFormat: .r8Unorm, planeIndex: 0)
            self.capturedImageCbCrTexture = self.makeTexture(fromPixelBuffer: frame.capturedImage, pixelFormat: .rg8Unorm, planeIndex: 1)
            
            guard let commandBuffer = self.commandQueue.makeCommandBuffer() else { fatalError("Couldn't create command buffer.") }
            commandBuffer.label = "the droids you're looking for"
            guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else { fatalError("Couldn't create command encoder.") }
            
            commandEncoder.setComputePipelineState(self.pipeline)

            self.gridPointsBuffer.assign(with: self.grid)
            
            commandEncoder.setBuffer(self.pointCloudUniformsBuffer, offset: 0)
            commandEncoder.setBuffer(self.pointUniformsBuffer, offset: 0)
            commandEncoder.setBuffer(self.gridPointsBuffer, offset: 0)
            
            
            var retainingTextures = [capturedImageYTexture, capturedImageCbCrTexture, depthTexture, confidenceTexture]
            commandBuffer.addCompletedHandler { buffer in
                retainingTextures.removeAll()
            }
            
            commandEncoder.setTexture(CVMetalTextureGetTexture(self.capturedImageYTexture!), index: Int(kTextureY.rawValue))
            commandEncoder.setTexture(CVMetalTextureGetTexture(self.capturedImageCbCrTexture!), index: Int(kTextureCbCr.rawValue))
            commandEncoder.setTexture(CVMetalTextureGetTexture(self.depthTexture!), index: Int(kTextureDepth.rawValue))
            commandEncoder.setTexture(CVMetalTextureGetTexture(self.confidenceTexture!), index: Int(kTextureConfidence.rawValue))
            
            commandBuffer.addCompletedHandler { [weak self] buffer in
                self?.retrieveResults()
            }

            let gridSize = MTLSize(width: self.grid.count, height: 1, depth: 1)
            
            var threadGroups = self.pipeline.maxTotalThreadsPerThreadgroup
            if threadGroups > self.grid.count {
                threadGroups = self.grid.count
            }
            let threadGroupSize = MTLSize(width: threadGroups, height: 1, depth: 1)
            
            commandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
            commandEncoder.endEncoding()

            commandBuffer.commit()
        }
    }
    
    
    private func shouldAccumulatePoints() -> Bool {
        if self.frameCounter >= 15 {
            self.frameCounter = 0
            return true
        } else {
            self.frameCounter += 1
            return false
        }
    }
    
    private func gridPoints() -> [simd_float2] {
        let gridArea = cameraResolution.x * cameraResolution.y
        let spacing = sqrt(Float(gridArea) / Float(self.pointCount))
        let deltaX = Int(round(Float(cameraResolution.x) / spacing))
        let deltaY = Int(round(Float(cameraResolution.y) / spacing))
        
        var points = [simd_float2]()
        for gridY in 0 ..< deltaY {
            let alternatingOffsetX = Float(gridY % 2) * spacing / 2
            for gridX in 0 ..< deltaX {
                let cameraPoint = simd_float2(alternatingOffsetX + (Float(gridX) + 0.5) * spacing, (Float(gridY) + 0.5) * spacing)
                
                points.append(cameraPoint)
            }
        }
        
        return points
    }
    
    private func retrieveResults() {
        for i in 0..<self.pointCount {
            let point = self.pointUniformsBuffer[i]
            if point.confidence >= self.confidenceThreshold {
                self.pointCloud.points.append(point.position)
                self.pointCloud.colors.append(point.color)
            }
        }
    }
    
    private func makeTextureCache() -> CVMetalTextureCache {
        var cache: CVMetalTextureCache!
        CVMetalTextureCacheCreate(nil, nil, device, nil, &cache)
        
        return cache
    }
    
    private func makeTexture(fromPixelBuffer pixelBuffer: CVPixelBuffer, pixelFormat: MTLPixelFormat, planeIndex: Int) -> CVMetalTexture? {
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
        
        var texture: CVMetalTexture? = nil
        let status = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache, pixelBuffer, nil, pixelFormat, width, height, planeIndex, &texture)
        
        if status != kCVReturnSuccess {
            texture = nil
        }

        return texture
    }
    
    static func cameraToDisplayRotation(orientation: UIInterfaceOrientation) -> Int {
        switch orientation {
        case .landscapeLeft:
            return 180
        case .portrait:
            return 90
        case .portraitUpsideDown:
            return -90
        default:
            return 0
        }
    }
    
    static func makeRotateToARCameraMatrix(orientation: UIInterfaceOrientation) -> matrix_float4x4 {
        let flipYZ = matrix_float4x4(
            [1, 0, 0, 0],
            [0, -1, 0, 0],
            [0, 0, -1, 0],
            [0, 0, 0, 1] )

        let rotationAngle = Float(cameraToDisplayRotation(orientation: orientation)) * (Float.pi / 180.0)
        return flipYZ * matrix_float4x4(simd_quaternion(rotationAngle, simd_float3(0, 0, 1)))
    }
}
