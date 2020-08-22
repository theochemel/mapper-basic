import Foundation
import UIKit
import ARKit

import Foundation
import UIKit
import ARKit

class ScanRecorderViewController: UIViewController, ScanRecorderDelegate {
        
    private var scanRecorder: ScanRecorder!
    private var scanRecorderView: ScanRecorderView!
    
    var delegate: ScanRecorderViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scanRecorder = ScanRecorder(orientation: UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.unknown,
                                         viewportSize: .zero)
        scanRecorder.delegate = self
        
        self.scanRecorderView = ScanRecorderView()
        self.view = self.scanRecorderView
        self.scanRecorderView.recordButton.addTarget(self, action: #selector(self.recordButtonDidTouchUpInside(_:)), for: .touchUpInside)
        
        self.scanRecorder.arViewProvider = self.scanRecorderView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.scanRecorder.startSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.parent?.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLayoutSubviews() {
        self.scanRecorder.orientationDidChange(UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.unknown)
        self.scanRecorder.viewportSizeDidChange(self.view.bounds.size)
    }
    
    @objc private func recordButtonDidTouchUpInside(_ sender: UIButton) {
        if self.scanRecorder.isRecording {
            sender.setTitle("RECORD", for: .normal)
            self.scanRecorder.stopRecording()
        } else {
            sender.setTitle("SAVE", for: .normal)
            self.scanRecorder.startRecording()
        }
    }
    
    func didFinishScan(pointCloud: PointCloud) {
        self.delegate?.didFinishScan(pointCloud: pointCloud)
    }
}
