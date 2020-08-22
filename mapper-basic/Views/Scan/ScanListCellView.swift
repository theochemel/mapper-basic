import Foundation
import SwiftUI

struct ScanListCellView: View {
    
    var scan: Scan
    var dateCreatedString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM y"
        return formatter.string(from: self.scan.dateCreated)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(scan.name)
                .font(.headline)
            Text(self.dateCreatedString)
                .font(.subheadline)
        }.padding([.top, .bottom], 10.0)
    }
}
