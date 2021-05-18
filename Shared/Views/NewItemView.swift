//
//  NewItemView.swift
//  Inventauri
//
//  Created by Daniel Marriner on 09/05/2021.
//

import SwiftUI
import CoreData
import Camera_SwiftUI
import Introspect

struct NewItemView: View {
    enum ActiveSheet: Identifiable {
        case picker, camera

        var id: Int { hashValue }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State var isAddingContainer: Bool

    @State var parent: Item
    @State private var showingCancelAlert = false
    @State private var showingSaveAlert = false
    @State private var activeSheet: ActiveSheet?

    @State private var itemName = ""
    @State private var imageData: Data?

    var body: some View {
        NavigationView {
            Group {
                TextField("Name", text: $itemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                HStack {
                    VStack {
                        Button {
                            activeSheet = .camera
                        } label: {
                            Text("Take Picture")
                        }
                        .foregroundColor(.accentColor)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)

                        Button {
                            activeSheet = .picker
                        } label: {
                            Text("Choose Picture")
                        }
                        .foregroundColor(.accentColor)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                    }

                    Button {
                        print("glyph")
                    } label: {
                        Text("Choose Glyph")
                    }
                    .foregroundColor(.accentColor)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                }
                if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 300, height: 300)
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .navigationBarTitle(Text("New \(isAddingContainer ? "Group" : "Item")"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button {
                    showingCancelAlert = true
                } label: {
                    Text("Cancel")
                }
                .alert(isPresented: $showingCancelAlert) {
                    Alert(
                        title: Text("Exit adding item?"),
                        message: Text("You will lose all entered information."),
                        primaryButton: .cancel(),
                        secondaryButton: .destructive(Text("Exit")) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                },
                trailing: Button {
                    guard itemName.trimmingCharacters(in: .whitespacesAndNewlines) != "" else { return }
                    showingSaveAlert = true
                } label: {
                    Text("Add")
                }
                .alert(isPresented: $showingSaveAlert) {
                    Alert(
                        title: Text("Save item?"),
                        message: Text("This will save the item into the current group."),
                        primaryButton: .cancel(),
                        secondaryButton: .default(Text("Save")) {
                            addItem()
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
            )
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                    case .camera:
                        NavigationView {
                            CameraView(
                                isShown: $activeSheet,
                                image: $imageData
                            )
                        }
                        .introspectViewController { view in
                            view.isModalInPresentation = true
                        }
                    case .picker: 
                        ImagePickerView(
                            isShown: $activeSheet,
                            image: $imageData
                        )
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.name = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
            newItem.isContainer = isAddingContainer
            newItem.parent = parent
            newItem.image = imageData

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
