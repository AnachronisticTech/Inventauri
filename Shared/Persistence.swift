//
//  Persistence.swift
//  Shared
//
//  Created by Daniel Marriner on 09/05/2021.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let base = Item.init(context: viewContext)
        base.timestamp = Date()
        base.name = "Base item"
        base.isContainer = true
        base.id = Constants.inventauriBaseID

        let group1 = Item.init(context: viewContext)
        group1.timestamp = Date()
        group1.name = "Test group 1"
        group1.isContainer = true
        group1.parent = base

        let group2 = Item.init(context: viewContext)
        group2.timestamp = Date()
        group2.name = "Test group 2"
        group2.isContainer = true
        group2.parent = base

        let group3 = Item.init(context: viewContext)
        group3.timestamp = Date()
        group3.name = "Test group 3"
        group3.isContainer = true
        group3.parent = group1

        let item1 = Item.init(context: viewContext)
        item1.timestamp = Date()
        item1.name = "Test item 1"
        item1.isContainer = false
        item1.parent = base

        let item2 = Item.init(context: viewContext)
        item2.timestamp = Date()
        item2.name = "Test item 2"
        item2.isContainer = false
        item2.parent = group1

        let item3 = Item.init(context: viewContext)
        item3.timestamp = Date()
        item3.name = "Test item 3"
        item3.isContainer = false
        item3.parent = group2

        let item4 = Item.init(context: viewContext)
        item4.timestamp = Date()
        item4.name = "Test item 4"
        item4.isContainer = false
        item4.parent = base

        let item5 = Item.init(context: viewContext)
        item5.timestamp = Date()
        item5.name = "Test item 5"
        item5.isContainer = false
        item5.parent = base

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Inventauri")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
