//
//  MoveToView.swift
//  Inventauri
//
//  Created by Daniel Marriner on 12/05/2021.
//

import SwiftUI
import CoreData
import ASCollectionView

struct MoveToView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var isPresented: ItemsByGroupView.ActiveSheet?

    @State var movingItem: Item
    @State var currentLocation: Item
    @State private var showingConfirmationAlert = false

    enum Section { case containers }

    var body: some View {
        ASCollectionView {
            ASCollectionViewSection<Section>(
                id: .containers,
                data: currentLocation.containers
            ) { item, _ in
                NavigationLink(destination: MoveToView(
                    isPresented: $isPresented,
                    movingItem: movingItem,
                    currentLocation: item
                )) {
                    ContainerView(item: item)
                }
            }
        }
        .layout{
            .grid(
                layoutMode: .adaptive(withMinItemSize: 165),
                itemSpacing: 10,
                lineSpacing: 10,
                itemSize: .estimated(90)
            )
        }
        .contentInsets(.init(top: 20, left: 0, bottom: 20, right: 0))
        .alwaysBounceVertical()
        .edgesIgnoringSafeArea(.all)
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
