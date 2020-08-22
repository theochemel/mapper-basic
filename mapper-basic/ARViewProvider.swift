import Foundation
import ARKit

protocol ARViewProvider: class {
    var arView: ARSCNView! { get }
}
