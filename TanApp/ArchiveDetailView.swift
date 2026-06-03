//
//  ArchiveDetailView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI

struct ArchiveDetailView: View {
    @EnvironmentObject private var store: ArchiveStore
    let archive: CityArchive

    @State private var commentText = ""
    @State private var photoCaption = ""
    @State private var showPhotoInput = false
    @State private var showEditor = false

    private var latestArchive: CityArchive {
        store.archive(with: archive.id) ?? archive
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero
                story
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
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Rectangle()
                .fill(Color.gray.opacity(0.18))
                .frame(height: 220)
                .overlay {
                    Image(systemName: latestArchive.category.icon)
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

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
                .lineSpacing(4)

            Button {
                store.selectedTab = .map
            } label: {
                Label("内置导航", systemImage: "location.north.line.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.tanPrimary)
        }
    }

    private var process: some View {
        Surface {
            Text("工序记录")
                .font(.system(size: 18, weight: .bold))
            ForEach(Array(latestArchive.craftProcess.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 10) {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.tanInk)
                        .clipShape(Circle())
                    Text(step)
                        .font(.system(size: 14))
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
                Button {
                    showPhotoInput.toggle()
                } label: {
                    Label("上传", systemImage: "camera.fill")
                }
                .font(.system(size: 13, weight: .bold))
            }

            if showPhotoInput {
                HStack {
                    TextField("照片说明", text: $photoCaption)
                        .textFieldStyle(.roundedBorder)
                    Button("发布") {
                        let caption = photoCaption.isEmpty ? "用户补充照片" : photoCaption
                        store.addPhoto(to: latestArchive, caption: caption)
                        photoCaption = ""
                        showPhotoInput = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.tanPrimary)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(latestArchive.photos) { photo in
                    VStack(alignment: .leading, spacing: 6) {
                        PhotoPlaceholder(caption: photo.caption)
                            .frame(height: 92)
                        Button {
                            store.likePhoto(photo, in: latestArchive)
                        } label: {
                            Label("\(photo.likes)", systemImage: "hand.thumbsup.fill")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(Color.tanPrimary)
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
                TextField("补充你看到的信息", text: $commentText)
                    .textFieldStyle(.roundedBorder)
                Button("发送") {
                    guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    store.addComment(to: latestArchive, text: commentText)
                    commentText = ""
                }
                .buttonStyle(.borderedProminent)
                .tint(.tanPrimary)
            }

            ForEach(latestArchive.comments) { comment in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(Color.tanPrimary.opacity(0.16))
                        .frame(width: 34, height: 34)
                        .overlay {
                            Text(String(comment.contributorName.prefix(1)))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.tanPrimary)
                        }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comment.contributorName)
                            .font(.system(size: 13, weight: .bold))
                        Text(comment.text)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        store.likeComment(comment, in: latestArchive)
                    } label: {
                        Label("\(comment.likes)", systemImage: "hand.thumbsup")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.tanPrimary)
                }
                .padding(.vertical, 8)
            }
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
