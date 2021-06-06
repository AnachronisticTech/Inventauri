//
//  NewItemView.swift
//  Inventauri
//
//  Created by Daniel Marriner on 09/05/2021.
//

import SwiftUI
import CoreData
import Introspect

struct NewItemView: View {
    enum ActiveSheet: Identifiable {
        case picker, camera

        var id: Int { hashValue }
    }

    enum ActiveAlert: Identifiable {
        case cancel, save, clearImage

        var id: Int { hashValue }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @StateObject var item: Item
    @State var parentId: UUID?

    init(creatingItem item: Item, withParentId parentId: UUID) {
        item.isContainer = false
        self._parentId = State(wrappedValue: parentId)
        self._item = StateObject(wrappedValue: item)
    }

    init(creatingGroup item: Item, withParentId parentId: UUID) {
        item.isContainer = true
        self._parentId = State(wrappedValue: parentId)
        self._item = StateObject(wrappedValue: item)
    }

    init(modifying item: Item) {
        self._item = StateObject(wrappedValue: item)
    }
    
    @State private var showingActionSheet = false
    @State private var activeSheet: ActiveSheet?
    @State private var activeAlert: ActiveAlert?

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $item.name)

                HStack {
                    Button("Glyph") {
                        print("glyph")
                    }
                }

                HStack {
                    Button("Image") {
                        showingActionSheet = true
                    }

                    Divider().frame(width: 5)

                    if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    }
                }

                if item.image != nil {
                    HStack {
                        Spacer()
                        Button("Remove Image") {
                            activeAlert = .clearImage
                        }
                        Spacer()
                    }
                }
            }
            .navigationBarTitle(
                Text(parentId != nil ? "New " : "Edit ") +
                Text(item.isContainer ? "Group" : "Item")
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    activeAlert = .cancel
                },
                trailing: Button("Save") {
                    guard item.name.trimmingCharacters(in: .whitespacesAndNewlines) != "" else { return }
                    activeAlert = .save
                }
            )
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(
                    title: Text("Choose image"),
                    buttons: [
                        .default(Text("Choose from library")) {
                            activeSheet = .picker
                        },
                        .default(Text("Take new photo")) {
                            activeSheet = .camera
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(item: $activeSheet) { _ in
                ImagePickerView(isShown: $activeSheet, image: $item.image)
                    .introspectViewController { view in
                        view.isModalInPresentation = true
                    }
            }
            .alert(item: $activeAlert) { alert in
                let title: String
                let message: String
                let secondaryButton: Alert.Button
                switch alert {
                    case .cancel:
                        title = "Discard these changes?"
                        message = "You will lose all entered information."
                        secondaryButton = .destructive(Text("Discard")) {
                            viewContext.rollback()
                            presentationMode.wrappedValue.dismiss()
                        }
                    case .save:
                        title = "Save?"
                        message = "This will save the item into the current group."
                        secondaryButton = .default(Text("Save")) {
                            addItem()
                            presentationMode.wrappedValue.dismiss()
                        }
                    case .clearImage:
                        title = "Remove image?"
                        message = "This will clear the currently assigned image."
                        secondaryButton = .destructive(Text("Remove")) {
                            item.image = nil
                        }
                }
                return Alert(
                    title: Text(title),
                    message: Text(message),
                    primaryButton: .cancel(),
                    secondaryButton: secondaryButton
                )
            }
        }
    }

    private func addItem() {
        withAnimation {
            item.name = item.name
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if item.timestamp == nil {
                item.timestamp = Date()
            }
            if let id = parentId, item.parent == nil {
                let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
                fetchRequest.fetchLimit = 1
                fetchRequest.predicate = NSPredicate(
                    format: "id == %@",
                    id as CVarArg
                )
                item.parent = try? viewContext.fetch(fetchRequest).first!
            }

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct NewItemView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(
            format: "id == %@",
            Constants.inventauriBaseID as CVarArg
        )
        let base = try! context.fetch(fetchRequest).first!

        let item = Item(context: context)
        item.parent = base
        item.timestamp = Date()
        return NewItemView(creatingItem: item, withParentId: base.id!)
            .environment(\.managedObjectContext, context)
    }
}
