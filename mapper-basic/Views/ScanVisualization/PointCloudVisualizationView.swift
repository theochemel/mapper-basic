import Foundation
import UIKit
import SceneKit

class PointCloudVisualizationView: UIView {
    
    public var sceneView: SCNView!
    
    public init() {
        super.init(frame: .zero)
        self.sceneView = SCNView()
        self.sceneView.backgroundColor = .clear
        self.addSubview(sceneView)
        self.setupSceneView()
        self.layoutSceneView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func draw(pointCloud: PointCloud) {
        self.sceneView.scene?.rootNode.childNode(withName: "pointCloud", recursively: true)?.removeFromParentNode()
        
        let pointsGeometrySource = SCNGeometrySource(vertices: pointCloud.points.map { SCNVector3($0) })
        
        var colorsData = Data(count: pointCloud.colors.count * 12)
        for i in 0..<pointCloud.colors.count {
            colorsData.replaceSubrange(i*12..<i*12+4, with: withUnsafeBytes(of: pointCloud.colors[i].x) { Data($0) })
            colorsData.replaceSubrange(i*12+4..<i*12+8, with: withUnsafeBytes(of: pointCloud.colors[i].y) { Data($0) })
            colorsData.replaceSubrange(i*12+8..<i*12+12, with: withUnsafeBytes(of: pointCloud.colors[i].z) { Data($0) })
        }
        let colorsGeometrySource = SCNGeometrySource(data: colorsData,
                                                     semantic: .color,
                                                     vectorCount: pointCloud.colors.count,
                                                     usesFloatComponents: true,
                                                     componentsPerVector: 3,
                                                     bytesPerComponent: 4,
                                                     dataOffset: 0,
                                                     dataStride: 12)
        
        let pointsGeometryElement = SCNGeometryElement(data: nil,
                                                       primitiveType: .point,
                                                       primitiveCount: pointCloud.points.count,
                                                       bytesPerIndex: 8)
        pointsGeometryElement.pointSize = 0.01
        pointsGeometryElement.minimumPointScreenSpaceRadius = 1.0
        pointsGeometryElement.maximumPointScreenSpaceRadius = 5.0
        
        let geometry = SCNGeometry(sources: [pointsGeometrySource, colorsGeometrySource], elements: [pointsGeometryElement])
        
        let node = SCNNode(geometry: geometry)
        node.name = "pointCloud"
        
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.lightingModel = .constant
        node.geometry?.firstMaterial? = material
        
        self.sceneView.scene?.rootNode.addChildNode(node)
    }
    
    private func setupSceneView() {
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.scene = SCNScene()
        self.sceneView.scene?.isPaused = false
        self.sceneView.allowsCameraControl = true
    }
    
    private func layoutSceneView() {
        self.sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.sceneView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.sceneView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.sceneView.topAnchor.constraint(equalTo: self.topAnchor),
            self.sceneView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
