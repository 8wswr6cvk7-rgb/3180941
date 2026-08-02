//
//  SystemCameraPicker.swift
//  TanApp
//

import AVFoundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SystemCameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let allowsVideo: Bool
    let onMediaPicked: (PendingImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = allowsVideo
            ? [UTType.image.identifier, UTType.movie.identifier]
            : [UTType.image.identifier]
        picker.videoQuality = .typeMedium
        picker.videoMaximumDuration = 60
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: SystemCameraPicker

        init(parent: SystemCameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onMediaPicked(PendingImage(image: image))
            } else if let videoURL = info[.mediaURL] as? URL,
                      let pending = PendingImage(videoURL: videoURL) {
                parent.onMediaPicked(pending)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
