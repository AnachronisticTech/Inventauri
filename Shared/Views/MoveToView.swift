//
//  MoveToView.swift
//  Inventauri
//
//  Created by Daniel Marriner on 12/05/2021.
//

import SwiftUI
import CoreData

struct MoveToView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var isPresented: ItemsByGroupView.ActiveSheet?

    @State var movingItem: Item
    @State var currentLocation: Item
    @State private var showingConfirmationAlert = false

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 165))]) {
                ForEach(currentLocation.containers) { item in
                    NavigationLink(destination: MoveToView(
                        isPresented: $isPresented,
                        movingItem: movingItem,
                        currentLocation: item
                    )) {
                        ContainerView(item: item)
                    }
                }
            }
            .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(currentLocation.wrappedName)
        .navigationBarItems(
            leading: Button("Cancel") {
                isPresented = nil
            },
            trailing:
                Button("Move here") {
                    guard movingItem != currentLocation else { return }
                    showingConfirmationAlert = true
                }
        )
        .alert(isPresented: $showingConfirmationAlert) {
            Alert(
                title: Text("Are you sure you want to move this here?"),
                message: Text("This will also relocate all containers and items within."),
                primaryButton: .cancel(),
                secondaryButton: .default(Text("Move")) {
                    movingItem.parent = currentLocation
                    do {
                        try viewContext.save()
                    } catch {
                        print("Unable to move item")
                    }
                    isPresented = nil
                }
            )
        }
    }
}

struct MoveToView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(
            format: "id == %@",
            Constants.inventauriBaseID as CVarArg
        )
        let base = try! context.fetch(fetchRequest).first!

        let item = Item.init(context: context)
        item.timestamp = Date()
        item.name = "Test item 1"
        item.isContainer = false
        item.parent = base

        return NavigationView {
            MoveToView(
                isPresented: .constant(nil),
                movingItem: item,
                currentLocation: base
            )
        }.environment(\.managedObjectContext, context)
    }
}
