//
//  AllItems.swift
//  Inventauri
//
//  Created by Daniel Marriner on 09/05/2021.
//

import SwiftUI
import CoreData
import NavigationSearchBar

struct AllItemsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var text: String = ""

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)],
        predicate: NSPredicate(format: "isContainer == %@", NSNumber(value: false))
    )
    private var items: FetchedResults<Item>

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 0) {
                Section(header: GridHeader(), footer: GridFooter()) {
                    ForEach(items.filter { $0.name.starts(with: text) }) { item in
                        ItemView(item: item, showingPath: true)
                        Divider()
                    }
                }
            }
            .padding(15)
        }
        .navigationBarTitle("All Items")
        .navigationBarTitleDisplayMode(.automatic)
        .navigationSearchBar(text: $text)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AllItemsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        return NavigationView {
            AllItemsView()
        }.environment(\.managedObjectContext, context)
    }
}
