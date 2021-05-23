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
        picker.sourceType = isShown == .picker ? .photoLibrary : .camera
        picker.allowsEditing = true
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
        defer { isCoordinatorShown = nil }

        guard var unwrappedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }

        if unwrappedImage.imageOrientation != .up {
            UIGraphicsBeginImageContextWithOptions(unwrappedImage.size, false, unwrappedImage.scale)
            unwrappedImage.draw(in: CGRect(x: 0, y: 0, width: unwrappedImage.size.width, height: unwrappedImage.size.height))
            unwrappedImage = UIGraphicsGetImageFromCurrentImageContext() ?? unwrappedImage
            UIGraphicsEndImageContext()
        }

        guard let image = unwrappedImage.cgImage else { return }
        var x = 0
        var y = 0
        let size = min(image.width, image.height)

        if image.height > image.width {
            y = (image.height - size) / 2
        } else {
            x = (image.width - size) / 2
        }

        guard let cropped = image.cropping(to: CGRect(x: x, y: y, width: size, height: size)) else { return }
        imageInCoordinator = UIImage(cgImage: cropped).pngData()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isCoordinatorShown = nil
    }
}
