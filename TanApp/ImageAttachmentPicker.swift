import AVFoundation
import PhotosUI
import SwiftUI
import UIKit

struct PendingImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ImageAttachmentPicker: View {
    @Binding var pendingImages: [PendingImage]
    let maximumSelectionCount: Int
    var emptyPrompt: String = "添加现场照片"

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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !pendingImages.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(3, maximumSelectionCount)), spacing: 8) {
                    ForEach(pendingImages) { pending in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: pending.image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 104)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                            Button {
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
                            .accessibilityLabel("移除这张待发布照片")
                        }
                    }
                }
            }

            if remainingCount > 0 {
                HStack(spacing: 10) {
                    Button {
                        requestCamera()
                    } label: {
                        Label("拍照", systemImage: "camera.fill")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(isLoadingPhotoItems)

                    PhotosPicker(
                        selection: $photoItems,
                        maxSelectionCount: remainingCount,
                        matching: .images
                    ) {
                        Label("从相册选择", systemImage: "photo.on.rectangle")
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
                    Text("正在读取照片…")
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
            SystemCameraPicker { image in
                append(image)
            }
        }
        .onChange(of: photoItems) { items in
            Task { await loadPhotoItems(items) }
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

    private func requestCamera() {
        permissionTitle = "无法使用相机"
        permissionMessage = "请允许相机权限后拍摄现场照片；你仍可继续填写文字或从相册选择图片。"
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
            if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                append(image)
            } else {
                loadError = "有图片无法读取，请重新选择或检查相册权限。"
                permissionTitle = "无法读取相册照片"
                permissionMessage = "请允许照片访问后重新选择图片；你仍可继续填写文字并发布。"
                showPermissionAlert = true
            }
        }
        photoItems = []
    }

    private func append(_ image: UIImage) {
        guard pendingImages.count < maximumSelectionCount else { return }
        pendingImages.append(PendingImage(image: image))
    }
}
