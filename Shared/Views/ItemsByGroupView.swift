//
//  ContentView.swift
//  Shared
//
//  Created by Daniel Marriner on 09/05/2021.
//

import SwiftUI
import CoreData
import Introspect

struct ItemsByGroupView: View {
    enum ActiveSheet: Identifiable {
        case add(isContainer: Bool = false)
        case move(item: Item, base: Item)
        case edit(item: Item)

        var id: Int {
            switch self {
                case .add(_): return 0
                case .move(_, _): return 1
                case .edit(_): return 2
            }
        }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item

    @State private var showingActionSheet = false
    @State private var showingDeleteAlert = false
    @State private var activeSheet: ActiveSheet?

    @State private var itemToDelete: Item?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 165))]) {
                ForEach(item.containers) { item in
                    NavigationLink(destination: ItemsByGroupView(item: item)) {
                        ContainerView(item: item)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 15))
                    .contextMenu {
                        Button {
                            activeSheet = .edit(item: item)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button {
                            activeSheet = .move(item: item, base: item.path[0])
                        } label: {
                            Label("Move", systemImage: "arrow.2.squarepath")
                        }
                        Divider()
                        Button {
                            itemToDelete = item
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))

            LazyVGrid(columns: [GridItem(.flexible())], spacing: 0) {
                Section(header: GridHeader(), footer: GridFooter()) {
                    ForEach(item.items) { item in
                        ItemView(item: item)
                            .contextMenu {
                                Button {
                                    activeSheet = .edit(item: item)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button {
                                    activeSheet = .move(item: item, base: item.path[0])
                                } label: {
                                    Label("Move", systemImage: "arrow.2.squarepath")
                                }
                                Divider()
                                Button {
                                    itemToDelete = item
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        Divider()
                    }
                }
            }
            .padding(15)
        }
        .navigationBarTitle(item.name)
        .navigationBarItems(trailing:
            Button {
                showingActionSheet = true
            } label: {
                Label("Add Item", systemImage: "plus")
            }
        )
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("What would you like to add?"),
                buttons: [
                    .default(Text("Add new item")) {
                        activeSheet = .add()
                    },
                    .default(Text("Add new group")) {
                        activeSheet = .add(isContainer: true)
                    },
                    .cancel()
                ]
            )
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
                case .add(true):
                    ItemEditFormView(
                        creatingGroup: Item(context: viewContext),
                        withParentId: item.id!
                    )
                    .environment(\.managedObjectContext, viewContext)
                    .introspectViewController { view in
                        view.isModalInPresentation = true
                    }
                case .add(false):
                    ItemEditFormView(
                        creatingItem: Item(context: viewContext),
                        withParentId: item.id!
                    )
                    .environment(\.managedObjectContext, viewContext)
                    .introspectViewController { view in
                        view.isModalInPresentation = true
                    }
                case .edit(let item):
                    ItemEditFormView(modifying: item)
                        .environment(\.managedObjectContext, viewContext)
                        .introspectViewController { view in
                            view.isModalInPresentation = true
                        }
                case .move(let itemToMove, let base):
                    NavigationView {
                        MoveToView(
                            isPresented: $activeSheet,
                            movingItem: itemToMove,
                            currentLocation: base
                        )
                    }
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Are you sure you want to delete this?"),
                message: Text("This will delete all containers and items within. This action cannot be undone."),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text("Delete")) {
                    guard let item = itemToDelete else { return }
                    viewContext.delete(item)
                    do {
                        try viewContext.save()
                    } catch {
                        print("Unable to delete item")
                    }
                    itemToDelete = nil
                }
            )
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { item.all[$0] }.forEach(viewContext.delete)

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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ItemsByGroupView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(
            format: "id == %@",
            Constants.inventauriBaseID as CVarArg
        )
        let base = try! context.fetch(fetchRequest).first!

        return NavigationView {
            ItemsByGroupView(item: base)
        }.environment(\.managedObjectContext, context)
    }
}
