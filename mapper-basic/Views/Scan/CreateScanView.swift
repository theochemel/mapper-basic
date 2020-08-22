import Foundation
import SwiftUI

import Foundation
import SwiftUI

struct CreateScanView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var description: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }
                Spacer()
                Button(action: {
                    self.save()
                }) {
                    Text("Save")
                }
            }
            .padding()
            
            Text("New Scan")
                .font(.largeTitle)
                .padding()
            
            Form {
                Section {
                    TextField("Name", text: self.$name)
                }
                Section {
                    TextField("Description", text: self.$description)
                }
            }
            Spacer()
        }
    }
    
    private func save() {
        guard self.name.count > 0, self.description.count > 0 else { return }
        let scan = Scan(context: self.managedObjectContext)
        scan.name = name
        scan.details = description
        scan.dateCreated = Date()
        
        do {
            try self.managedObjectContext.save()
        } catch (let error) {
            fatalError("CoreData save failed: \(error.localizedDescription)")
        }
        
        self.presentationMode.wrappedValue.dismiss()
    }
}

