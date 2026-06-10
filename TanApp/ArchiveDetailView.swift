//
//  ArchiveDetailView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI
import PhotosUI
import UIKit

struct ArchiveDetailView: View {
    @EnvironmentObject private var store: ArchiveStore
    let archive: CityArchive

    @State private var commentText = ""
    @State private var photoCaption = ""
    @State private var showPhotoInput = false
    @State private var showEditor = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    private var latestArchive: CityArchive {
        store.archive(with: archive.id) ?? archive
    }

    private var canUploadPhoto: Bool {
        store.selectedRole == .visitor
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero
                story
                activityRange
                process
                photoWall
                comments
            }
            .padding(16)
            .padding(.bottom, 20)
        }
        .background(Color.tanPaper.ignoresSafeArea())
        .navigationTitle(latestArchive.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if store.selectedRole == .stallOwner && latestArchive.isUserCreated {
                        Button {
                            showEditor = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundStyle(Color.tanPrimary)
                        }
                    }

                    Button {
                        store.toggleFavorite(latestArchive)
                    } label: {
                        Image(systemName: store.favoriteIDs.contains(latestArchive.id) ? "heart.fill" : "heart")
                            .foregroundStyle(Color.tanPrimary)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                AIArchiveBuilderView(editingArchive: latestArchive)
                    .environmentObject(store)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                selectedPhotoData = image.jpegData(compressionQuality: 0.82)
                showPhotoInput = true
            }
        }
        .onChange(of: selectedPhotoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        selectedPhotoData = data
                        showPhotoInput = true
                    }
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                LinearGradient(
                    colors: [Color.tanPrimary.opacity(0.28), Color.heritageGreen.opacity(0.18), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 12) {
                    Image(systemName: latestArchive.category.icon)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                        .frame(width: 96, height: 96)
                        .background(.white.opacity(0.82))
                        .clipShape(RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous))
                        .shadow(color: Color.tanInk.opacity(0.08), radius: 14, x: 0, y: 8)
                    Text(latestArchive.category.title)
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.tanInk)
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(.white.opacity(0.78))
                        .clipShape(Capsule())
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous)
                    .stroke(Color.white.opacity(0.75))
            }
            .shadow(color: Color.tanInk.opacity(0.08), radius: 16, x: 0, y: 9)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(latestArchive.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.tanInk)
                    Text("\(latestArchive.ownerName) · \(latestArchive.category.title) · \(latestArchive.yearsActive) 年")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                StatusBadge(status: latestArchive.status)
            }

            FlowTags(tags: latestArchive.tags)
        }
    }

    private var story: some View {
        Surface {
            Text("档案故事")
                .font(.system(size: 18, weight: .bold))
            Text(latestArchive.summary)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .lineSpacing(6)

            Button {
                store.navigateToArchiveOnMap(latestArchive)
            } label: {
                Label("内置导航", systemImage: "location.north.line.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.tanPrimary)
        }
    }

    private var activityRange: some View {
        Surface {
            HStack {
                Label("常驻活动范围", systemImage: "map.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.tanInk)
                Spacer()
                Button {
                    store.navigateToArchiveOnMap(latestArchive)
                } label: {
                    Text("在地图看")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.tanPrimary)
            }

            Text("这些地点来自档案里的常驻点、周末点和节庆流动点。")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineSpacing(3)

            if latestArchive.historicalStops.isEmpty {
                EmptyStateView(text: "还没有活动范围记录，等待摊主开摊补充。")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(latestArchive.historicalStops) { stop in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(stop.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color.tanInk)
                                Text(stop.appearedAt)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .frame(minWidth: 118, alignment: .leading)
                            .background(Color.tanPaper)
                            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
                        }
                    }
                }
            }
        }
    }

    private var process: some View {
        Surface {
            Text("工序记录")
                .font(.system(size: 18, weight: .bold))
            ForEach(Array(latestArchive.craftProcess.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 4) {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.tanPrimary)
                            .clipShape(Circle())
                        if index < latestArchive.craftProcess.count - 1 {
                            Rectangle()
                                .fill(Color.tanLine)
                                .frame(width: 2, height: 24)
                        }
                    }
                    Text(step)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.tanInk.opacity(0.76))
                        .padding(.top, 4)
                    Spacer()
                }
            }
        }
    }

    private var photoWall: some View {
        Surface {
            HStack {
                Text("用户照片")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                if canUploadPhoto {
                    Button {
                        showPhotoInput.toggle()
                    } label: {
                        Label("上传", systemImage: "camera.fill")
                    }
                    .font(.system(size: 13, weight: .bold))
                }
            }

            if showPhotoInput {
                VStack(alignment: .leading, spacing: 10) {
                    if let selectedPhotoData {
                        UploadedPhotoPreview(imageData: selectedPhotoData, caption: photoCaption.isEmpty ? "待发布照片" : photoCaption)
                            .frame(height: 160)
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.tanPrimary.opacity(0.08))
                            .frame(height: 110)
                            .overlay {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 28, weight: .bold))
                                    Text("先拍照或从相册选择一张现场照片")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .foregroundStyle(Color.tanPrimary)
                            }
                    }

                    ChineseFriendlyTextField(placeholder: "照片说明", text: $photoCaption)
                        .padding(.horizontal, 12)
                        .frame(height: 38)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous)
                                .stroke(Color.tanLine)
                        }

                    HStack(spacing: 10) {
                        Button {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                showCamera = true
                            } else {
                                selectedPhotoData = makeMockCameraPhotoData()
                            }
                        } label: {
                            Label("拍照", systemImage: "camera.fill")
                        }
                        .buttonStyle(.bordered)

                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("从相册选择", systemImage: "photo.fill.on.rectangle.fill")
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button("发布") {
                            let caption = photoCaption.isEmpty ? "用户补充现场照片" : photoCaption
                            store.addPhoto(to: latestArchive, caption: caption, imageData: selectedPhotoData)
                            photoCaption = ""
                            selectedPhotoData = nil
                            selectedPhotoItem = nil
                            showPhotoInput = false
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.tanPrimary)
                        .disabled(selectedPhotoData == nil)
                    }
                    .font(.system(size: 13, weight: .bold))
                }
            }

            if latestArchive.photos.isEmpty {
                EmptyStateView(text: "还没有街景照片，成为第一个补档的人。")
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    ForEach(latestArchive.photos) { photo in
                        VStack(alignment: .leading, spacing: 6) {
                            UploadedPhotoPreview(imageData: photo.imageData, caption: photo.caption)
                                .frame(height: 96)
                            Button {
                                store.likePhoto(photo, in: latestArchive)
                            } label: {
                                Label("\(photo.likes)", systemImage: store.hasLikedPhoto(photo) ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .font(.system(size: 12, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .frame(height: 26)
                                    .background(Color.tanPaper)
                                    .clipShape(Capsule())
                            }
                            .foregroundStyle(Color.tanPrimary)
                            .disabled(store.hasLikedPhoto(photo))
                        }
                    }
                }
            }
        }
    }

    private var comments: some View {
        Surface {
            Text("评论与补档")
                .font(.system(size: 18, weight: .bold))
            HStack {
                ChineseFriendlyTextField(placeholder: "补充你看到的信息", text: $commentText)
                    .padding(.horizontal, 12)
                    .frame(height: 38)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous)
                            .stroke(Color.tanLine)
                    }
                Button("发送") {
                    guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    store.addComment(to: latestArchive, text: commentText)
                    commentText = ""
                }
                .buttonStyle(.borderedProminent)
                .tint(.tanPrimary)
            }

            if latestArchive.comments.isEmpty {
                EmptyStateView(text: "还没有街坊补档，来留下第一条线索。")
            } else {
                ForEach(latestArchive.comments) { comment in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(Color.tanPrimary.opacity(0.16))
                            .frame(width: 38, height: 38)
                            .overlay {
                                Text(String(comment.contributorName.prefix(1)))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.tanPrimary)
                            }
                        VStack(alignment: .leading, spacing: 5) {
                            Text(comment.contributorName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.tanInk)
                            Text(comment.text)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .lineSpacing(3)
                        }
                        Spacer()
                        Button {
                            store.likeComment(comment, in: latestArchive)
                        } label: {
                            Label("\(comment.likes)", systemImage: store.hasLikedComment(comment) ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .padding(.horizontal, 9)
                                .frame(height: 30)
                                .background(Color.tanPaper)
                                .clipShape(Capsule())
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                        .disabled(store.hasLikedComment(comment))
                    }
                    .padding(12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                            .stroke(Color.tanLine)
                    }
                }
            }
        }
    }

    private func makeMockCameraPhotoData() -> Data? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 900, height: 650))
        let image = renderer.image { context in
            UIColor(Color.tanPrimary.opacity(0.22)).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 900, height: 650))

            UIColor(Color.tanPaper).setFill()
            UIBezierPath(roundedRect: CGRect(x: 70, y: 70, width: 760, height: 510), cornerRadius: 44).fill()

            UIColor(Color.tanPrimary).setFill()
            UIBezierPath(ovalIn: CGRect(x: 390, y: 225, width: 120, height: 120)).fill()

            let title = "现场拍照模拟"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48, weight: .black),
                .foregroundColor: UIColor(Color.tanInk)
            ]
            title.draw(at: CGPoint(x: 285, y: 375), withAttributes: attributes)
        }
        return image.jpegData(compressionQuality: 0.82)
    }

}

private struct UploadedPhotoPreview: View {
    let imageData: Data?
    let caption: String

    var body: some View {
        Group {
            if let imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.18))
            }
        }
        .overlay(alignment: .bottomLeading) {
            Text(caption)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.tanInk)
                .lineLimit(2)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.72))
        }
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
    }
}

private struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker

        init(parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

private struct FlowTags: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    TagPill(text: tag)
                }
            }
        }
    }
}
