//
//  ImageCaptureView.swift
//  Inventauri (iOS)
//
//  Created by Daniel Marriner on 16/05/2021.
//

import SwiftUI

struct ImagePickerView: View {
    @Binding var isShown: NewItemView.ActiveSheet?
    @Binding var image: Data?

    func makeCoordinator() -> ImageCaptureViewCoordinator {
        ImageCaptureViewCoordinator(isShown: $isShown, image: $image)
    }
}

extension ImagePickerView: UIViewControllerRepresentable {
    typealias Context = UIViewControllerRepresentableContext<ImagePickerView>

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }
}

class ImageCaptureViewCoordinator:
    NSObject,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate
{
    @Binding var isCoordinatorShown: NewItemView.ActiveSheet?
    @Binding var imageInCoordinator: Data?

    init(isShown: Binding<NewItemView.ActiveSheet?>, image: Binding<Data?>) {
        _isCoordinatorShown = isShown
        _imageInCoordinator = image
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let unwrappedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
//        imageInCoordinator = Image(uiImage: unwrappedImage)
        imageInCoordinator = unwrappedImage.pngData()
        isCoordinatorShown = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isCoordinatorShown = nil
    }
}
