import Foundation
import CoreData

@objc(Scan)
public class Scan: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var details: String
    @NSManaged public var dateCreated: Date
    @NSManaged public var isCompleted: Bool
    @NSManaged public var pointCount: Int
    @NSManaged public var points: NSData
    @NSManaged public var colors: NSData
    
    public func didFinishScan(pointCloud: PointCloud) {
        self.isCompleted = true
        self.pointCount = pointCloud.points.count
        self.points = pointCloud.pointsData()
        self.colors = pointCloud.colorsData()
    }
    
    public var pointCloud: PointCloud {
        get {
            return PointCloud(pointCount: self.pointCount,  pointsNSData: self.points, colorsNSData: self.colors)
        }
    }
}
