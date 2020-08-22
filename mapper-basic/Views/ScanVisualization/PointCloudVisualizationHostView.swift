import Foundation
import SwiftUI

struct PointCloudVisualizationHostView: UIViewControllerRepresentable {
    var pointCloud: PointCloud
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PointCloudVisualizationHostView>) -> PointCloudVisualizationViewController {
        
        let pointCloudVisualizationViewController = PointCloudVisualizationViewController()
        pointCloudVisualizationViewController.pointCloud = self.pointCloud
        return pointCloudVisualizationViewController
    }
    
    func updateUIViewController(_ uiViewController: PointCloudVisualizationViewController, context: UIViewControllerRepresentableContext<PointCloudVisualizationHostView>) {
    }
}
