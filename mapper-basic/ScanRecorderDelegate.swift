import Foundation

protocol ScanRecorderDelegate: class {
    func didFinishScan(pointCloud: PointCloud)
}
