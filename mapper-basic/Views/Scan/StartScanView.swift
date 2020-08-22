import Foundation
import SwiftUI

struct StartScanView: View {
    @ObservedObject var scan: Scan
    
    var body: some View {
        VStack {
            Text("Scan has not been completed.")
            NavigationLink(destination: ScanRecorderHostView(scan: scan)
            .edgesIgnoringSafeArea([.top, .bottom])
            ) {
                Text("Start Scan")
            }
        }
    }
}
