//
//  HomeView.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import SwiftUI

enum HomeTab: Hashable {
    case map
    case discover
    case profile
}

struct HomeView: View {
    @State private var selectedTab: HomeTab = .map

    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tag(HomeTab.map)
                .tabItem {
                    Label("地图", systemImage: "map")
                }

            DiscoverView()
                .tag(HomeTab.discover)
                .tabItem {
                    Label("发现", systemImage: "list.bullet.rectangle")
                }

            ProfileView()
                .tag(HomeTab.profile)
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle")
                }
        }
        .tint(.tanPrimary)
        .toolbarBackground(.white, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environmentObject(TanAppModel())
        }
    }
}
