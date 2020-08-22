//
//  mapper_basicApp.swift
//  mapper-basic
//
//  Created by Theo Chemel on 8/19/20.
//

import SwiftUI
import CoreData

@main
struct mapper_basicApp: App {
    
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ScanListView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }.onChange(of: scenePhase) { phase in
            if phase == .background {
                saveContext()
            }
        }
    }
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "mapper-basic")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
