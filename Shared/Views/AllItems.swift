//
//  AllItems.swift
//  Inventauri
//
//  Created by Daniel Marriner on 09/05/2021.
//

import SwiftUI
import CoreData
import ASCollectionView
import NavigationSearchBar

struct AllItems: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var text: String = ""

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Item.name, ascending: true)
        ],
        predicate: NSPredicate(format: "isContainer == %@", NSNumber(value: false)),
        animation: .default
    )
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            ASCollectionView(data: items.filter { $0.wrappedName.starts(with: text) }) { item, context in
                VStack(spacing: 0) {
                    ItemView(item: item, showingPath: true)
//                        .onDelete(perform: deleteItems)
                    if !context.isLastInSection {
                        Divider()
                    }
                }
            }
            .layout {
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
                    return section
                }
            }
            .contentInsets(.init(top: 20, left: 0, bottom: 20, right: 0))
            .alwaysBounceVertical()
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle("All Items")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationSearchBar(text: $text)
        }
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
