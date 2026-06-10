//
//  RootView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: ArchiveStore

    var body: some View {
        Group {
            if store.isLoggedIn {
                HomeView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.isLoggedIn)
    }
}

struct LoginView: View {
    @EnvironmentObject private var store: ArchiveStore
    @State private var selectedRole: AppRole = .visitor

    var body: some View {
        ZStack {
            Color.tanPaper.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Spacer(minLength: 18)

                VStack(alignment: .leading, spacing: 16) {
                    Text("摊")
                        .font(.system(size: 76, weight: .black))
                        .foregroundStyle(Color.tanInk)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("记录成都街头的烟火气")
                            .font(.system(size: 25, weight: .black))
                            .foregroundStyle(Color.tanInk)
                        Text("摊位、手艺、故事、路线，都可以被看见。")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.tanInk.opacity(0.68))
                            .lineSpacing(4)
                    }

                    HStack(spacing: 8) {
                        TagPill(text: "成都市井档案")
                        TagPill(text: "老手艺保护")
                        TagPill(text: "社区补档")
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    LinearGradient(
                        colors: [Color.tanPrimary.opacity(0.18), .white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: TanRadius.xlarge, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: TanRadius.xlarge, style: .continuous)
                        .stroke(Color.white.opacity(0.75), lineWidth: 1)
                }
                .shadow(color: Color.tanInk.opacity(0.08), radius: 18, x: 0, y: 10)

                VStack(alignment: .leading, spacing: 12) {
                    Text("你今天想怎么进入？")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.tanInk)

                    HStack(spacing: 12) {
                        roleButton(.visitor, icon: "figure.walk", title: "我想逛摊", subtitle: "找小吃、老手艺和街角故事")
                        roleButton(.stallOwner, icon: "storefront.fill", title: "我要建档", subtitle: "AI 帮我整理摊位档案")
                    }
                }

                Button {
                    store.login(as: selectedRole)
                } label: {
                    Text("进入摊档地图")
                }
                .buttonStyle(PrimaryButtonStyle())

                Spacer()

                Text(store.cloudState)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(24)
        }
    }

    private func roleButton(_ role: AppRole, icon: String, title: String, subtitle: String) -> some View {
        Button {
            selectedRole = role
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 42, height: 42)
                    .background(selectedRole == role ? .white.opacity(0.18) : Color.tanPrimary.opacity(0.12))
                    .clipShape(Circle())
                Text(title)
                    .font(.system(size: 17, weight: .black))
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(selectedRole == role ? .white.opacity(0.82) : Color.tanInk.opacity(0.58))
                    .lineLimit(2)
            }
            .foregroundStyle(selectedRole == role ? .white : Color.tanInk)
            .frame(maxWidth: .infinity)
            .frame(height: 136)
            .padding(14)
            .background(selectedRole == role ? Color.tanPrimary : .white)
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous)
                    .stroke(selectedRole == role ? Color.tanPrimary.opacity(0.45) : Color.tanLine)
            }
            .shadow(color: selectedRole == role ? Color.tanPrimary.opacity(0.22) : Color.tanInk.opacity(0.05), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: selectedRole)
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: ArchiveStore

    var body: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                ArchiveMapView()
            }
            .tag(AppTab.map)
            .tabItem {
                Label("地图", systemImage: "map")
            }

            if store.selectedRole == .visitor {
                NavigationStack {
                    DiscoverView()
                }
                .tag(AppTab.discover)
                .tabItem {
                    Label("发现", systemImage: "square.grid.2x2")
                }
            }

            if store.selectedRole == .stallOwner {
                NavigationStack {
                    AIArchiveBuilderView()
                }
                .tag(AppTab.build)
                .tabItem {
                    Label("建档", systemImage: "sparkles")
                }
            }

            NavigationStack {
                ProfileView()
            }
            .tag(AppTab.profile)
            .tabItem {
                Label("我的", systemImage: "person.crop.circle")
            }
        }
        .tint(.tanPrimary)
        .fixedWhiteTabBar()
    }
}
