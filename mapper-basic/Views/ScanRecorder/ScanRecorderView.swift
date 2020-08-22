import Foundation
import UIKit
import RealityKit
import ARKit

class ScanRecorderView: UIView, ARViewProvider {
    
    public var arView: ARSCNView!
    public var recordButton: UIButton!
    
    public init() {
        super.init(frame: .zero)
        
        self.arView = ARSCNView()
        self.addSubview(arView)
        self.layoutARView()
        
        self.recordButton = {
            let button = UIButton()
            button.setTitle("RECORD", for: .normal)
            button.titleLabel?.font = .monospacedSystemFont(ofSize: button.titleLabel?.font.pointSize ?? 12.0, weight: .regular)
            button.setTitleColor(.systemRed, for: .normal)
            button.layer.cornerRadius = 18.0
            button.clipsToBounds = true
            
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
            
            blurView.frame = button.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.isUserInteractionEnabled = false
            
            button.insertSubview(blurView, at: 0)
            
            return button
        }()
        self.addSubview(recordButton)
        self.layoutRecordButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutARView() {
        self.arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            arView.topAnchor.constraint(equalTo: self.topAnchor),
            arView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func layoutRecordButton() {
        self.recordButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 128.0),
            recordButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -32.0),
            recordButton.heightAnchor.constraint(equalToConstant: 36.0)
        ])
    }
}
