//
//  InventauriApp.swift
//  Shared
//
//  Created by Daniel Marriner on 09/05/2021.
//

import SwiftUI
import CoreData

struct Constants {
    static let inventauriBaseID = UUID(uuidString: "d48c18ec-5670-4533-a7df-7839cc01ccb5")!
}

@main
struct InventauriApp: App {
    let persistenceController = PersistenceController.shared
    let base: Item

    init() {
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(
            format: "id == %@",
            Constants.inventauriBaseID as CVarArg
        )
        guard let base = try? persistenceController
                .container
                .viewContext
                .fetch(fetchRequest)
                .first
        else {
            let baseItem = Item(context: persistenceController.container.viewContext)
            baseItem.timestamp = Date()
            baseItem.name = "Inventauri"
            baseItem.isContainer = true
            baseItem.id = Constants.inventauriBaseID
            do {
                try persistenceController.container.viewContext.save()
            } catch {
                fatalError("Could not retrieve or create base container")
            }
            self.base = baseItem
//            print("all initialised fine!")
            return
        }
        self.base = base
//        print("all initialised fine!")
    }

    @State var selectedTab = 0

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                NavigationView {
                    ItemsByGroupView(item: base)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
                .tabItem {
                    Image(systemName: "circle.grid.cross.fill")
                    Text("My Groups")
                }

                NavigationView {
                    AllItemsView()
                }
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
                .tabItem {
                    Text("All Items")
                }
            }
        }
    }
}
