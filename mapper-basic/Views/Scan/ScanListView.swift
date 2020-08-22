import Foundation
import SwiftUI

struct ScanListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Scan.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Scan.dateCreated, ascending: true)
        ]
    ) var scans: FetchedResults<Scan>
    
    @State private var isShowingCreateScanView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.scans, id: \.self) { scan in
                    NavigationLink(destination: ScanView(scan: scan).navigationBarTitle("", displayMode: .inline)) {
                        ScanListCellView(scan: scan)
                    }
                }
            }.navigationBarTitle("Scans")
            .navigationBarItems(trailing:
                HStack {
                    Button(action: { self.isShowingCreateScanView.toggle() }) {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .padding()
                    }
                    .sheet(isPresented: self.$isShowingCreateScanView) {
                        CreateScanView().environment(\.managedObjectContext, self.managedObjectContext)
                    }
                    EditButton()
                })
        }
    }
}
