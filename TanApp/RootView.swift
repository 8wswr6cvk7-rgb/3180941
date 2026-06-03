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

            VStack(alignment: .leading, spacing: 22) {
                Spacer(minLength: 30)

                Text("摊")
                    .font(.system(size: 64, weight: .black))
                    .foregroundStyle(Color.tanInk)

                Text("市井档案与老手艺保护平台")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.tanInk)

                Text("先选择身份进入。用户侧重找档、拍照、评论与点赞；摊户侧重 AI 建档、开摊定位与接收反馈。")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)

                HStack(spacing: 12) {
                    roleButton(.visitor, icon: "person.fill")
                    roleButton(.stallOwner, icon: "storefront.fill")
                }

                Button {
                    store.login(as: selectedRole)
                } label: {
                    Text("进入档案库")
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

    private func roleButton(_ role: AppRole, icon: String) -> some View {
        Button {
            selectedRole = role
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                Text(role.title)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(selectedRole == role ? .white : Color.tanInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(selectedRole == role ? Color.tanPrimary : .white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.tanLine)
            }
        }
        .buttonStyle(.plain)
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

            NavigationStack {
                DiscoverView()
            }
            .tag(AppTab.discover)
            .tabItem {
                Label("发现", systemImage: "square.grid.2x2")
            }

            NavigationStack {
                AIArchiveBuilderView()
            }
            .tag(AppTab.build)
            .tabItem {
                Label("建档", systemImage: "sparkles")
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
