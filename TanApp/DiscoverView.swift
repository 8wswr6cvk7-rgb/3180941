//
//  DiscoverView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var store: ArchiveStore
    @State private var query = ""
    @State private var selectedCategory: ArchiveCategory?

    private var archives: [CityArchive] {
        store.searchArchives(query: query, category: selectedCategory)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                recommendBanner
                searchBar
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    hotKeywordsView
                }
                categoryTabs

                Text("附近摊位与街巷记忆")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.tanInk)

                if archives.isEmpty {
                    EmptyStateView(text: "暂时没找到这个摊，换个关键词试试。", icon: "magnifyingglass")
                } else {
                    ForEach(archives) { archive in
                        NavigationLink(value: ArchiveDetailRoute.top(archive.id)) {
                            ArchiveRow(archive: archive)
                        }
                        .buttonStyle(.plain)
                        .frame(minHeight: 44)
                    }
                }
            }
            .padding(16)
        }
        .background(Color.tanPaper.ignoresSafeArea())
        .navigationTitle("发现")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: ArchiveDetailRoute.self) { route in
            if let archive = store.archive(with: route.archiveID) {
                ArchiveDetailView(archive: archive, initialSection: route.initialSection)
            }
        }
    }

    private var recommendBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("今日城市记忆")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.tanPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.8))
                .clipShape(Capsule())

            Text("发现仍在街巷发生的手艺")
                .font(.system(size: 25, weight: .black))
                .foregroundStyle(Color.tanInk)

            Text("从一处摊位出发，认识手艺人、街巷故事与可能消失的城市记忆。")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.tanInk.opacity(0.68))
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            LinearGradient(
                colors: [Color.tanPrimary.opacity(0.18), .white],
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

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.tanPrimary)
            ChineseFriendlyTextField(placeholder: "搜索非遗、老行当、小吃、地点", text: $query)
        }
        .padding(.horizontal, 15)
        .frame(height: 46)
        .background(.white)
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(Color.tanLine)
        }
        .shadow(color: Color.tanInk.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private var hotKeywordsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("从这些记忆开始")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.tanInk.opacity(0.62))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ArchiveStore.discoveryKeywords, id: \.self) { keyword in
                        Button {
                            query = keyword
                        } label: {
                            TagPill(text: keyword)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedCategory = nil
                } label: {
                    TagPill(text: "全部 \(store.archives.count)", isSelected: selectedCategory == nil)
                }
                .buttonStyle(.plain)
                .frame(minHeight: 44)
                ForEach(store.availableCategories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12, weight: .bold))
                            Text("\(category.title) \(count(for: category))")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(selectedCategory == category ? .white : Color.tanInk)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory == category ? Color.tanPrimary : Color.tanPaper)
                        .clipShape(Capsule())
                        .overlay {
                            Capsule().stroke(selectedCategory == category ? Color.tanPrimary.opacity(0.55) : Color.tanLine)
                        }
                        .shadow(color: selectedCategory == category ? Color.tanPrimary.opacity(0.14) : .clear, radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .frame(minHeight: 44)
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: selectedCategory)
    }

    private func count(for category: ArchiveCategory) -> Int {
        store.archives.filter { $0.category == category }.count
    }
}
