import Foundation
import UIKit

class PointCloudVisualizationViewController: UIViewController {
    
    var pointCloud: PointCloud!
    var pointCloudVisualizationView: PointCloudVisualizationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pointCloudVisualizationView = PointCloudVisualizationView()
        self.view = self.pointCloudVisualizationView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pointCloudVisualizationView.draw(pointCloud: self.pointCloud)
    }
}
