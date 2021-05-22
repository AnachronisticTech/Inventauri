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
                    ForEach(items.filter { $0.wrappedName.starts(with: text) }) { item in
                        ItemView(item: item, showingPath: true)
                        Divider()
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15))
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
        let context = PersistenceController.shared.container.viewContext
        let base = Item.init(context: context)
        base.timestamp = Date()
        base.name = "Base item"
        base.isContainer = true

//        let group1 = Item.init(context: context)
//        group1.timestamp = Date()
//        group1.name = "Test group 1"
//        group1.isContainer = true
//        group1.parent = base

//        let group2 = Item.init(context: context)
//        group2.timestamp = Date()
//        group2.name = "Test group 2"
//        group2.isContainer = true
//        group2.parent = base

        let item1 = Item.init(context: context)
        item1.timestamp = Date()
        item1.name = "Test item 1"
        item1.isContainer = false
        item1.parent = base

//        let item2 = Item.init(context: context)
//        item2.timestamp = Date()
//        item2.name = "Test item 2"
//        item2.isContainer = false
//        item2.parent = group1

//        let item3 = Item.init(context: context)
//        item3.timestamp = Date()
//        item3.name = "Test item 3"
//        item3.isContainer = false
//        item3.parent = group2

        return NavigationView {
            AllItemsView()
        }.environment(\.managedObjectContext, context)
    }
}
