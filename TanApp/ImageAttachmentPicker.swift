import AVFoundation
import CoreTransferable
import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct PendingImage: Identifiable {
    let id = UUID()
    let image: UIImage
    let videoURL: URL?

    var mediaType: AttachmentMediaType {
        videoURL == nil ? .image : .video
    }

    init(image: UIImage) {
        self.image = image
        videoURL = nil
    }

    init?(videoURL: URL) {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 1_280, height: 1_280)
        guard let cgImage = try? generator.copyCGImage(
            at: CMTime(seconds: 0.1, preferredTimescale: 600),
            actualTime: nil
        ) else {
            return nil
        }
        image = UIImage(cgImage: cgImage)
        self.videoURL = videoURL
    }
}

private struct PickedVideo: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let pathExtension = received.file.pathExtension.isEmpty
                ? "mov"
                : received.file.pathExtension
            let copyURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(pathExtension)
            try FileManager.default.copyItem(at: received.file, to: copyURL)
            return PickedVideo(url: copyURL)
        }
    }
}

enum AttachmentPreviewStyle {
    case photo4x3
    case square

    var aspectRatio: CGFloat {
        switch self {
        case .photo4x3:
            return 4.0 / 3.0
        case .square:
            return 1.0
        }
    }
}

struct ImageAttachmentPicker: View {
    @Binding var pendingImages: [PendingImage]
    let maximumSelectionCount: Int
    var emptyPrompt: String = "添加现场照片"
    var singleImagePreviewStyle: AttachmentPreviewStyle = .photo4x3
    var allowsVideos = false

    @State private var photoItems: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    @State private var permissionTitle = "无法使用相机"
    @State private var permissionMessage = "请允许相机权限后拍摄现场照片；你仍可继续填写文字或从相册选择图片。"
    @State private var loadError: String?
    @State private var isLoadingPhotoItems = false

    private var remainingCount: Int {
        max(0, maximumSelectionCount - pendingImages.count)
    }

    private var previewColumns: [GridItem] {
        if pendingImages.count <= 1 {
            return [GridItem(.flexible())]
        }
        return [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible())
        ]
    }

    private var itemPreviewStyle: AttachmentPreviewStyle {
        pendingImages.count == 1 ? singleImagePreviewStyle : .square
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !pendingImages.isEmpty {
                LazyVGrid(columns: previewColumns, spacing: 8) {
                    ForEach(pendingImages) { pending in
                        pendingImagePreview(pending)
                    }
                }
            }

            if remainingCount > 0 {
                HStack(spacing: 10) {
                    Button {
                        requestCamera()
                    } label: {
                        Label(allowsVideos ? "拍照/录像" : "拍照", systemImage: "camera.fill")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(isLoadingPhotoItems)

                    PhotosPicker(
                        selection: $photoItems,
                        maxSelectionCount: remainingCount,
                        matching: allowsVideos ? .any(of: [.images, .videos]) : .images
                    ) {
                        Label(
                            allowsVideos ? "相册照片/视频" : "从相册选择",
                            systemImage: "photo.on.rectangle"
                        )
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(isLoadingPhotoItems)
                }
                .font(.system(size: 13, weight: .bold))
            }

            if isLoadingPhotoItems {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text(allowsVideos ? "正在读取影像…" : "正在读取照片…")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
            }

            if pendingImages.isEmpty {
                Text(emptyPrompt)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            if let loadError {
                Text(loadError)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.warningRed)
            }
        }
        .sheet(isPresented: $showCamera) {
            SystemCameraPicker(allowsVideo: allowsVideos) { pending in
                append(pending)
            }
        }
        .onChange(of: photoItems) { items in
            Task { await loadPhotoItems(items) }
        }
        .onDisappear {
            for pending in pendingImages {
                guard let videoURL = pending.videoURL else { continue }
                try? FileManager.default.removeItem(at: videoURL)
            }
        }
        .alert(permissionTitle, isPresented: $showPermissionAlert) {
            Button("前往设置") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text(permissionMessage)
        }
    }

    private func pendingImagePreview(_ pending: PendingImage) -> some View {
        ZStack(alignment: .topTrailing) {
            GeometryReader { proxy in
                Image(uiImage: pending.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }

            Button {
                if let videoURL = pending.videoURL {
                    try? FileManager.default.removeItem(at: videoURL)
                }
                pendingImages.removeAll { $0.id == pending.id }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Color.tanInk)
                    .frame(width: 28, height: 28)
                    .background(.white.opacity(0.94))
                    .clipShape(Circle())
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                pending.mediaType == .video ? "移除这段待发布视频" : "移除这张待发布照片"
            )

            if pending.mediaType == .video {
                Image(systemName: "play.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.black.opacity(0.58))
                    .clipShape(Circle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(itemPreviewStyle.aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
    }

    private func requestCamera() {
        permissionTitle = "无法使用相机"
        permissionMessage = allowsVideos
            ? "请允许相机权限后拍摄现场照片或视频；你仍可继续填写文字或从相册选择。"
            : "请允许相机权限后拍摄现场照片；你仍可继续填写文字或从相册选择图片。"
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showPermissionAlert = true
            return
        }
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { showCamera = true } else { showPermissionAlert = true }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            showPermissionAlert = true
        }
    }

    private func loadPhotoItems(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        isLoadingPhotoItems = true
        defer { isLoadingPhotoItems = false }
        loadError = nil
        for item in items.prefix(remainingCount) {
            if allowsVideos,
               item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
                if let pickedVideo = try? await item.loadTransferable(type: PickedVideo.self),
                   let pending = PendingImage(videoURL: pickedVideo.url) {
                    append(pending)
                } else {
                    showLoadFailure(for: "视频")
                }
            } else if let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) {
                append(PendingImage(image: image))
            } else {
                showLoadFailure(for: "照片")
            }
        }
        photoItems = []
    }

    private func append(_ pending: PendingImage) {
        guard pendingImages.count < maximumSelectionCount else { return }
        pendingImages.append(pending)
    }

    private func showLoadFailure(for itemName: String) {
        loadError = "有\(itemName)无法读取，请重新选择或检查相册权限。"
        permissionTitle = "无法读取相册内容"
        permissionMessage = "请允许照片访问后重新选择；你仍可继续填写文字并发布。"
        showPermissionAlert = true
    }
}
