import Foundation
import SwiftUI

struct ScanView: View {
    @ObservedObject var scan: Scan
    
    var dateCreatedString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM y"
        return formatter.string(from: self.scan.dateCreated)
    }
    
    @State private var isDisplayingShareSheet = false

    var body: some View  {
        HStack {
            VStack {
                VStack(alignment: .leading, spacing: 12.0) {
                    HStack {
                        Text(self.scan.name)
                            .font(.largeTitle)
                        Spacer()
                        if self.scan.isCompleted {
                            Button(action: {
                                self.isDisplayingShareSheet = true
                            }) {
                                Image(systemName: "square.and.arrow.up")
                            }.sheet(isPresented: $isDisplayingShareSheet) {
                                ActivityView(activityItems: [scan.pointCloud.export()], applicationActivities: nil)
                            }
                        }
                    }
                    HStack {
                        Text(self.scan.details)
                        Spacer()
                        Text("Created on \(self.dateCreatedString)")
                    }
                    Divider()
                }.padding([.top, .leading, .trailing], 24.0)
                Spacer()
                if self.scan.isCompleted {
                    PointCloudVisualizationHostView(pointCloud: self.scan.pointCloud)
                } else {
                    StartScanView(scan: self.scan)
                }
                Spacer(minLength: 0.0)
            }
        }
    }
}
