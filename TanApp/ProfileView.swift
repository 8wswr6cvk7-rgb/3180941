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
                .fill(Color.gray.opacity(0.18))
                .frame(width: 68, height: 68)
                .overlay {
                    Image(systemName: store.selectedRole == .stallOwner ? "storefront.fill" : "person.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.tanPrimary)
                }
            VStack(alignment: .leading, spacing: 6) {
                Text(store.user.name)
                    .font(.system(size: 24, weight: .bold))
                Text(store.selectedRole == .stallOwner ? "摊户 · AI 建档与开摊管理" : "用户 · 拍照评论获得市景侠积分")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var contributionCard: some View {
        Surface {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("市景侠积分")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text("\(store.user.points)")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                    Text("来自照片点赞、评论点赞与补档贡献")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(store.user.rank)
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.tanPaper)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
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
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("摊户工作台")
                        .font(.system(size: 20, weight: .bold))
                    Text("AI agent 会多轮追问、生成档案、再根据用户反馈持续补充信息。")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    store.selectedTab = .build
                } label: {
                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.tanPrimary)
                        .clipShape(Circle())
                }
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
                        .font(.system(size: 20, weight: .bold))
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
