//
//  InventauriApp.swift
//  Shared
//
//  Created by Daniel Marriner on 09/05/2021.
//

import SwiftUI

@main
struct InventauriApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
