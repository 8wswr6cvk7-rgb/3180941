//
//  ProfileView.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appModel: TanAppModel
    @State private var favoritesExpanded = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 14) {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 68, height: 68)
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.gray.opacity(0.6))
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(appModel.currentUser.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.tanSecondary)
                        Text("记录和守护成都街头烟火")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }

                SectionCard {
                    Text("市井侠积分")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(appModel.currentUser.points)")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(Color.tanPrimary)
                            Text("本周继续打卡可解锁更多摊位故事")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(appModel.rankingText)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.tanSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.tanBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            favoritesExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text("我收藏的摊位")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.tanSecondary)

                            Text("\(appModel.favoriteStalls.count)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.tanPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.tanPrimary.opacity(0.12))
                                .clipShape(Capsule())

                            Spacer()

                            Image(systemName: favoritesExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    if favoritesExpanded {
                        if appModel.favoriteStalls.isEmpty {
                            SectionCard {
                                Text("还没有收藏摊位，去地图或发现页看看吧。")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            ForEach(appModel.favoriteStalls) { stall in
                                NavigationLink {
                                    StallDetailView(stall: stall)
                                } label: {
                                    FavoriteStallRow(stall: stall)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                VStack(spacing: 12) {
                    NavigationLink {
                        RegisterStallView()
                    } label: {
                        ProfileEntryRow(
                            title: "我要开摊",
                            subtitle: appModel.hasRegisteredStall ? "更新我的数字摊位档案" : "去建一张属于街头的数字名片",
                            icon: "camera.aperture"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        OrdersView()
                    } label: {
                        ProfileEntryRow(
                            title: "我的代购订单",
                            subtitle: "查看已发布和已接单的帮带请求",
                            icon: "bag"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(Color.tanBackground.ignoresSafeArea())
        .navigationTitle("我的")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FavoriteStallRow: View {
    let stall: Stall

    var body: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 76, height: 76)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.gray.opacity(0.6))
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(stall.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.tanSecondary)
                Text("\(stall.category) · \(stall.price)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                StatusBadge(status: stall.status)
            }

            Spacer()
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct ProfileEntryRow: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.tanPrimary)
                .frame(width: 42, height: 42)
                .background(Color.tanPrimary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.tanSecondary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
                .environmentObject(TanAppModel())
        }
    }
}
