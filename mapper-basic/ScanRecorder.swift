import Foundation
import ARKit

class ScanRecorder: NSObject, ARSessionDelegate {
    
    public var isRecording = false
        
    public var pointCloudManager: PointCloudManager? = nil
    
    weak var delegate: ScanRecorderDelegate?
    weak var arViewProvider: ARViewProvider!
      
    private var orientation: UIInterfaceOrientation!
    private var viewportSize: CGSize!
    
    public init(orientation: UIInterfaceOrientation, viewportSize: CGSize) {
        self.orientation = orientation
        self.viewportSize = viewportSize
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard self.isRecording else { return }
        
        self.pointCloudManager?.update(from: frame)
    }
  
    public func startSession() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.sceneReconstruction = .mesh
        config.environmentTexturing = .none
        config.isLightEstimationEnabled = true
        config.isAutoFocusEnabled = false
        config.frameSemantics = [.sceneDepth]
        self.arViewProvider.arView.rendersMotionBlur = false
        self.arViewProvider.arView.automaticallyUpdatesLighting = true
        self.arViewProvider.arView.autoenablesDefaultLighting = false
        self.arViewProvider.arView.session.run(config, options: [])
        self.arViewProvider.arView.session.delegate = self
    }
    
    public func startRecording() {
        self.pointCloudManager = PointCloudManager()
        self.pointCloudManager?.orientation = orientation
        self.pointCloudManager?.viewportSize = viewportSize
        
        self.isRecording = true
    }
    
    public func stopRecording() {
        self.isRecording = false
    
        if let pointCloud = self.pointCloudManager?.pointCloud {
            self.delegate?.didFinishScan(pointCloud: pointCloud)
        }
    }
    
    public func orientationDidChange(_ orientation: UIInterfaceOrientation) {
        self.orientation = orientation
        self.pointCloudManager?.orientation = orientation
    }
    
    public func viewportSizeDidChange(_ size: CGSize) {
        self.viewportSize = size
        self.pointCloudManager?.viewportSize = size
    }
}
