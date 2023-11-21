//
//  ImagePicker.swift
//  rps-ios
//
//  Created by serika on 2023/11/20.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    struct ImageInfo: Equatable {
        let image: UIImage
        let imageURL: String
    }
    
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: ImageInfo

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
               let url = info[UIImagePickerController.InfoKey.imageURL] as? URL
            {
                parent.selectedImage = ImageInfo(image: image, imageURL: url.absoluteString)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}

private struct PreviewView: View {
    @State var imageInfo = ImagePicker.ImageInfo(image: UIImage(), imageURL: "")
    
    @State var show = false
    var body: some View {
        VStack {
            Image(uiImage: imageInfo.image)
                .resizable()
                .frame(width: 200, height: 200)
            Button("click") {
                show = true
            }
        }
        .sheet(isPresented: $show, content: {
            ImagePicker(selectedImage: $imageInfo)
        })
    }
}
#Preview {
    PreviewView()
}
