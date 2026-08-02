//
//  ProfileView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: ArchiveStore
    @State private var favoritesExpanded = true
    @State private var showProfileEditor = false

    private var favorites: [CityArchive] {
        store.archives.filter { store.favoriteIDs.contains($0.id) }
    }

    private var ownerArchives: [CityArchive] {
        store.currentUserArchives
    }

    private var archivesWithCommunityClues: [CityArchive] {
        ownerArchives.filter { communityClueCount(in: $0) > 0 }
    }

    private var receivedContributionCount: Int {
        ownerArchives.reduce(0) { total, archive in
            total
                + archive.comments.filter { $0.contributorName != store.user.name }.count
                + archive.photos.filter { $0.contributorName != store.user.name }.count
        }
    }

    private var receivedStatusCount: Int {
        ownerArchives.reduce(0) { total, archive in
            total + archive.statusConfirmations.filter { $0.contributorName != store.user.name }.count
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                profileHeader
                if store.selectedRole == .visitor {
                    xilianCard
                    visitorFootprintCard
                    favoritesPanel
                } else {
                    stallOwnerOverviewCard
                    stallOwnerPanel
                    receivedCommunityPanel
                }
            }
            .padding(16)
        }
        .background(Color.tanPaper.ignoresSafeArea())
        .navigationTitle("我的")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showProfileEditor) {
            ProfileEditorSheet()
                .environmentObject(store)
        }
        .navigationDestination(for: ArchiveDetailRoute.self) { route in
            if let archive = store.archive(with: route.archiveID) {
                ArchiveDetailView(archive: archive, initialSection: route.initialSection)
            }
        }
    }

    private var profileHeader: some View {
        Button {
            showProfileEditor = true
        } label: {
            HStack(spacing: 14) {
                ProfileAvatarView(size: 72)
                VStack(alignment: .leading, spacing: 7) {
                    Text(store.user.name)
                        .font(.system(size: 25, weight: .black))
                        .foregroundStyle(Color.tanInk)
                    Text(profileTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.tanInk.opacity(0.62))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(Color.tanInk.opacity(0.38))
            }
            .padding(18)
            .background {
                LinearGradient(
                    colors: [.white, Color.tanPrimary.opacity(0.12)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous)
                    .stroke(Color.white.opacity(0.8))
            }
            .shadow(color: Color.tanInk.opacity(0.07), radius: 16, x: 0, y: 9)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("编辑头像和昵称，查看称号")
    }

    private var profileTitle: String {
        store.selectedRole == .stallOwner ? "摊户 · AI 建档管理" : "市景侠 · 社区补档者"
    }

    private var visitorFootprintCard: some View {
        Surface {
            Text("我的守护足迹")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.tanInk)

            HStack(spacing: 10) {
                ProfileStatCard(number: "\(favorites.count)", label: "守护")
                ProfileStatCard(number: "\(store.visitedArchiveIDs.count)", label: "到访")
                ProfileStatCard(number: "\(store.litArchiveIDs.count)", label: "点亮")
            }

            Text("发布补档后会留下到访记录；守护与点亮也能随时回看。")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.tanInk.opacity(0.58))
        }
    }

    private var stallOwnerOverviewCard: some View {
        Surface {
            Text("档案维护概览")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.tanInk)

            HStack(spacing: 10) {
                ProfileStatCard(number: "\(ownerArchives.count)", label: "我的档案")
                ProfileStatCard(number: "\(receivedContributionCount)", label: "社区补档")
                ProfileStatCard(number: "\(receivedStatusCount)", label: "状态线索")
            }

            Text("集中查看自己建立的档案，以及社区为这些档案留下的新内容。")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.tanInk.opacity(0.58))
        }
    }

    private var xilianCard: some View {
        Button {
            store.selectedTab = .map
        } label: {
            HStack(spacing: 13) {
                XilianAnimatedAvatarView(state: .idle, size: .medium)
                VStack(alignment: .leading, spacing: 5) {
                    Text("昔涟 · 城市记忆向导")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(Color.tanInk)
                    Text("去地图上点一点摊位，让昔涟沿路线陪你认识它的故事。")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color.tanPrimary)
            }
            .padding(15)
            .background {
                LinearGradient(
                    colors: [Color.white, Color(red: 1, green: 0.92, blue: 0.95)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                    .stroke(Color.tanLine)
            }
            .shadow(color: Color.tanInk.opacity(0.05), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var stallOwnerPanel: some View {
        Surface {
            ProfileActionRow(
                icon: "sparkles",
                title: "摊户工作台",
                subtitle: "用自然语言整理新档案，或继续完善已有记录。"
            ) {
                store.selectedTab = .build
            }

            Text("我的档案")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.tanInk)

            if ownerArchives.isEmpty {
                EmptyStateView(text: "还没有建立档案，先记录一个熟悉的摊吧。", icon: "sparkles")
            } else {
                ForEach(ownerArchives) { archive in
                    NavigationLink(value: ArchiveDetailRoute.top(archive.id)) {
                        ArchiveRow(archive: archive)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var receivedCommunityPanel: some View {
        Surface {
            Text("收到的社区线索")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.tanInk)
            Text("评论、现场影像和状态确认会汇总到对应档案中。")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            if ownerArchives.isEmpty {
                EmptyStateView(text: "建立档案后，这里会显示社区留下的补充线索。", icon: "bubble.left.and.bubble.right")
            } else if archivesWithCommunityClues.isEmpty {
                EmptyStateView(text: "暂时还没有收到社区线索。", icon: "bubble.left.and.bubble.right")
            } else {
                ForEach(archivesWithCommunityClues) { archive in
                    NavigationLink(value: ArchiveDetailRoute.community(archive.id)) {
                        StallOwnerCommunityRow(
                            archive: archive,
                            contributionCount: communityContributionCount(in: archive),
                            statusCount: communityStatusCount(in: archive)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var favoritesPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    favoritesExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("守护清单")
                        .font(.system(size: 20, weight: .black))
                    Text("\(favorites.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                    Spacer()
                    Image(systemName: favoritesExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(Color.tanInk)
            }
            .buttonStyle(.plain)
            .padding(16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                    .stroke(Color.tanLine)
            }
            .shadow(color: Color.tanInk.opacity(0.05), radius: 10, x: 0, y: 6)

            if favoritesExpanded {
                if favorites.isEmpty {
                    EmptyStateView(text: "还没有守护的档案，去地图上发现一个吧。", icon: "heart")
                } else {
                    ForEach(favorites) { archive in
                        NavigationLink(value: ArchiveDetailRoute.top(archive.id)) {
                            ArchiveRow(archive: archive)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func communityContributionCount(in archive: CityArchive) -> Int {
        archive.comments.filter { $0.contributorName != store.user.name }.count
            + archive.photos.filter { $0.contributorName != store.user.name }.count
    }

    private func communityStatusCount(in archive: CityArchive) -> Int {
        archive.statusConfirmations.filter { $0.contributorName != store.user.name }.count
    }

    private func communityClueCount(in archive: CityArchive) -> Int {
        communityContributionCount(in: archive) + communityStatusCount(in: archive)
    }
}

private struct ProfileStatCard: View {
    let number: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(number)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color.tanPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.tanPaper)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
    }
}

private struct ProfileActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.tanPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(Color.tanInk)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color.tanPaper)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct StallOwnerCommunityRow: View {
    let archive: CityArchive
    let contributionCount: Int
    let statusCount: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: archive.category.icon)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Color.tanPrimary)
                .frame(width: 44, height: 44)
                .background(Color.tanPrimary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(archive.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.tanInk)
                    .lineLimit(1)
                Text("\(contributionCount) 条补档 · \(statusCount) 条状态线索")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color.tanPaper)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(archive.name)，\(contributionCount) 条社区补档，\(statusCount) 条状态线索")
    }
}

private struct ProfileAvatarView: View {
    @EnvironmentObject private var store: ArchiveStore
    let size: CGFloat
    @State private var image: UIImage?

    var body: some View {
        Circle()
            .fill(Color.tanPrimary.opacity(0.18))
            .frame(width: size, height: size)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else {
                    Image(systemName: store.selectedRole == .stallOwner ? "storefront.fill" : "person.fill")
                        .font(.system(size: size * 0.42, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                }
            }
            .task(id: store.user.avatarAttachment?.id) {
                guard let attachment = store.user.avatarAttachment else {
                    image = nil
                    return
                }
                image = await store.image(for: attachment)
            }
    }
}

private struct ProfileEditorSheet: View {
    @EnvironmentObject private var store: ArchiveStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var pendingImages: [PendingImage] = []
    @State private var removeExistingAvatar = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var title: String {
        store.selectedRole == .stallOwner ? "摊户 · 档案维护者" : "市景侠 · 社区补档者"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Spacer()
                        if let pending = pendingImages.first {
                            Image(uiImage: pending.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 104, height: 104)
                                .clipShape(Circle())
                        } else if removeExistingAvatar {
                            defaultAvatar
                        } else {
                            ProfileAvatarView(size: 104)
                        }
                        Spacer()
                    }

                    ImageAttachmentPicker(
                        pendingImages: $pendingImages,
                        maximumSelectionCount: 1,
                        emptyPrompt: "拍摄头像，或从相册选择一张照片",
                        singleImagePreviewStyle: .square
                    )

                    if store.user.avatarAttachment != nil,
                       pendingImages.isEmpty,
                       !removeExistingAvatar {
                        Button(role: .destructive) {
                            removeExistingAvatar = true
                        } label: {
                            Label("移除当前头像", systemImage: "trash")
                        }
                        .font(.system(size: 13, weight: .bold))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("昵称")
                            .font(.system(size: 14, weight: .black))
                        TextField("输入昵称", text: $name)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(Color.tanPaper)
                            .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("我的称号")
                            .font(.system(size: 14, weight: .black))
                        Label(title, systemImage: "medal.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.tanPrimary)
                        Label(store.user.rank, systemImage: "chart.bar.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("称号由当前身份和社区贡献生成，暂不支持手动修改。")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.tanPaper)
                    .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.warningRed)
                    }
                }
                .padding(18)
            }
            .background(Color.tanPaper.ignoresSafeArea())
            .navigationTitle("编辑个人资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "保存中…" : "保存") {
                        save()
                    }
                    .fontWeight(.bold)
                    .disabled(
                        isSaving ||
                        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
        }
        .onAppear {
            name = store.user.name
        }
        .interactiveDismissDisabled(isSaving)
    }

    private var defaultAvatar: some View {
        Circle()
            .fill(Color.tanPrimary.opacity(0.18))
            .frame(width: 104, height: 104)
            .overlay {
                Image(systemName: store.selectedRole == .stallOwner ? "storefront.fill" : "person.fill")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(Color.tanPrimary)
            }
    }

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        errorMessage = nil
        Task {
            do {
                try await store.updateProfile(
                    name: name,
                    avatarImage: pendingImages.first,
                    removeExistingAvatar: removeExistingAvatar
                )
                dismiss()
            } catch {
                errorMessage = "头像保存失败，请重试或继续使用当前头像。"
                isSaving = false
            }
        }
    }
}
