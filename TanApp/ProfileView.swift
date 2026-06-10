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

    private var favorites: [CityArchive] {
        store.archives.filter { store.favoriteIDs.contains($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                profileHeader
                contributionCard
                roleSwitch
                if store.selectedRole == .stallOwner {
                    stallOwnerPanel
                }
                favoritesPanel
            }
            .padding(16)
        }
        .background(Color.tanPaper.ignoresSafeArea())
        .navigationTitle("我的")
        .navigationBarTitleDisplayMode(.inline)
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
                Text(store.cloudState)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.tanPrimary)
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
    }

    private var contributionCard: some View {
        Surface {
            Text("市景侠积分")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.tanInk)

            HStack(spacing: 10) {
                ProfileStatCard(number: "\(store.user.points)", label: "积分")
                ProfileStatCard(number: store.user.rank, label: "排名")
                ProfileStatCard(number: "\(favorites.count)", label: "守护")
            }

            Text("积分来自照片点赞、评论点赞与补档贡献。")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.tanInk.opacity(0.58))
        }
    }

    private var roleSwitch: some View {
        Surface {
            Text("身份切换")
                .font(.system(size: 18, weight: .bold))
            Picker("身份", selection: Binding(get: {
                store.selectedRole
            }, set: { role in
                store.switchRole(to: role)
            })) {
                ForEach(AppRole.allCases, id: \.self) { role in
                    Text(role.title).tag(role)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var stallOwnerPanel: some View {
        Surface {
            ProfileActionRow(
                icon: "sparkles",
                title: "摊户工作台",
                subtitle: "AI 追问、生成档案，再吸收用户反馈补充信息。"
            ) {
                store.selectedTab = .build
            }

            ForEach(store.currentUserArchives) { archive in
                ArchiveRow(archive: archive)
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
                    EmptyStateView(text: "还没有收藏档案。")
                } else {
                    ForEach(favorites) { archive in
                        NavigationLink(value: archive.id) {
                            ArchiveRow(archive: archive)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationDestination(for: UUID.self) { id in
            if let archive = store.archive(with: id) {
                ArchiveDetailView(archive: archive)
            }
        }
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
