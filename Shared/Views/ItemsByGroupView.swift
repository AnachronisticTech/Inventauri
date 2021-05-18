//
//  ContentView.swift
//  Shared
//
//  Created by Daniel Marriner on 09/05/2021.
//

import SwiftUI
import CoreData
import ASCollectionView
import Introspect

struct ItemsByGroupView: View {
    enum ActiveSheet: Identifiable {
        case add, move(item: Item, base: Item)

        var id: Int {
            switch self {
                case .add: return 0
                case .move(_, _): return 1
            }
        }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item

    @State private var showingActionSheet = false
    @State private var showingDeleteAlert = false
    @State private var isAddingContainer = false
    @State private var activeSheet: ActiveSheet?

    @State private var itemToDelete: Item?

    enum Section { case items, containers }

    var body: some View {
//            List {
//                ForEach(item.childrenArray) { item in
//                    if item.isContainer {
//                        NavigationLink(
//                            destination: ItemsByGroupView(item: item)
//                        ) {
//                            Text(item.name!)
//                        }
//                    } else {
//                        Text(item.name!)
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
        ASCollectionView {
            ASCollectionViewSection<Section>(
                id: .containers,
                data: item.containers
            ) { item, _ in
                NavigationLink(destination: ItemsByGroupView(item: item)) {
                    ContainerView(item: item)
                }
                .contextMenu {
                    Button {
                        print("pressed")
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
            ASCollectionViewSection<Section>(
                id: .items,
                data: item.items
            ) { item, context in
                VStack(spacing: 0) {
                    ItemView(item: item)
                        .contextMenu {
                            Button {
                                print("pressed")
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
                    if !context.isLastInSection {
                        Divider()
                    }
                }
            }
            .sectionHeader {
                Text("Loose Items")
                    .font(.headline)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .sectionFooter { Text("") }
        }
        .layout(layout)
        .contentInsets(.init(top: 20, left: 0, bottom: 20, right: 0))
        .alwaysBounceVertical()
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle(item.wrappedName)
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
                        activeSheet = .add
                        isAddingContainer = false
                    },
                    .default(Text("Add new group")) {
                        activeSheet = .add
                        isAddingContainer = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
                case .add:
                    NewItemView(
                        isAddingContainer: isAddingContainer,
                        parent: item
                    )
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

    let groupBackgroundId = UUID().uuidString

    var layout: ASCollectionLayout<Section> {
        ASCollectionLayout<Section>(interSectionSpacing: 20) { id in
            switch id {
                case .containers:
                    return .grid(
                        layoutMode: .adaptive(withMinItemSize: 165),
                        itemSpacing: 10,
                        lineSpacing: 10,
                        itemSize: .estimated(90)
                    )
                case .items:
                    return ASCollectionLayoutSection {
                        let itemSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(60)
                        )
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        let groupSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(60)
                        )
                        let group = NSCollectionLayoutGroup
                            .horizontal(
                                layoutSize: groupSize,
                                subitems: [item]
                            )
                        let section = NSCollectionLayoutSection(group: group)
                        section.contentInsets = NSDirectionalEdgeInsets(
                            top: 0, leading: 20,
                            bottom: 0, trailing: 20
                        )
                        let supplementarySize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(50)
                        )
                        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: supplementarySize,
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top)
                        let footerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: supplementarySize,
                            elementKind: UICollectionView.elementKindSectionFooter,
                            alignment: .bottom
                        )
                        section.boundarySupplementaryItems = [headerSupplementary, footerSupplementary]
                        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem
                            .background(elementKind: groupBackgroundId)
                        sectionBackgroundDecoration.contentInsets = section.contentInsets
                        section.decorationItems = [sectionBackgroundDecoration]
                        return section
                    }
            }
        }
        .decorationView(
            GroupBackground.self,
            forDecorationViewOfKind: groupBackgroundId
        )
    }
}

struct GroupBackground: View, Decoration {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
