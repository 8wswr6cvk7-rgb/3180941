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
#if DEBUG
    @State private var showDemoResetConfirmation = false
    @State private var isResettingDemo = false
#endif

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
        .navigationDestination(for: ArchiveDetailRoute.self) { route in
            if let archive = store.archive(with: route.archiveID) {
                ArchiveDetailView(archive: archive, initialSection: route.initialSection)
            }
        }
#if DEBUG
        .confirmationDialog("恢复比赛演示数据？", isPresented: $showDemoResetConfirmation, titleVisibility: .visible) {
            Button(isResettingDemo ? "正在恢复…" : "恢复统一 Seed 数据", role: .destructive) {
                guard !isResettingDemo else { return }
                isResettingDemo = true
                Task {
                    await store.resetCompetitionDemoData()
                    isResettingDemo = false
                }
            }
            .disabled(isResettingDemo)
        } message: {
            Text("将清除本机新增档案、补档图片、点赞、到访与状态线索，并恢复比赛 Seed 数据。")
        }
#endif
    }

    private var profileHeader: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.tanPrimary.opacity(0.18))
                .frame(width: 72, height: 72)
                .overlay {
                    Image(systemName: store.selectedRole == .stallOwner ? "storefront.fill" : "person.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                }
            VStack(alignment: .leading, spacing: 7) {
                Text(store.user.name)
                    .font(.system(size: 25, weight: .black))
                    .foregroundStyle(Color.tanInk)
                Text(store.selectedRole == .stallOwner ? "摊户 · AI 建档管理" : "市景侠 · 社区补档者")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.tanInk.opacity(0.62))
            }
            Spacer()
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
#if DEBUG
        .onLongPressGesture(minimumDuration: 2) {
            showDemoResetConfirmation = true
        }
#endif
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
            Text("评论、现场照片和状态确认会汇总到对应档案中。")
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
