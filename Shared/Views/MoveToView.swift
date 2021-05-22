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
            trailing:
                Button {
                    guard movingItem != currentLocation else { return }
                    showingConfirmationAlert = true
                } label: {
                    Text("Move here")
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
        let context = PersistenceController.shared.container.viewContext
        let base = Item.init(context: context)
        base.timestamp = Date()
        base.name = "Base item"
        base.isContainer = true

        let item = Item.init(context: context)
        item.timestamp = Date()
        item.name = "Test item 1"
        item.isContainer = false
        item.parent = base

        let group1 = Item.init(context: context)
        group1.timestamp = Date()
        group1.name = "Test group 1"
        group1.isContainer = true
        group1.parent = base

        let group2 = Item.init(context: context)
        group2.timestamp = Date()
        group2.name = "Test group 2"
        group2.isContainer = true
        group2.parent = base

        return NavigationView {
            MoveToView(
                isPresented: .constant(nil),
                movingItem: item,
                currentLocation: base
            )
        }.environment(\.managedObjectContext, context)
    }
}
