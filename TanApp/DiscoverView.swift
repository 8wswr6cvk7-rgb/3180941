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

    private let hotKeywords = ["小吃", "修补", "非遗", "消失预警", "玉林路"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                recommendBanner
                searchBar
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    hotKeywordsView
                }
                categoryTabs

                Text("市井档案 + 老手艺 / 非遗")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.tanInk)

                if archives.isEmpty {
                    EmptyStateView(text: "暂时没找到这个摊，换个关键词试试。", icon: "magnifyingglass")
                } else {
                    ForEach(archives) { archive in
                        NavigationLink(value: archive.id) {
                            ArchiveRow(archive: archive)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .background(Color.tanPaper.ignoresSafeArea())
        .navigationTitle("发现")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: UUID.self) { id in
            if let archive = store.archive(with: id) {
                ArchiveDetailView(archive: archive)
            }
        }
    }

    private var recommendBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("今日值得守护")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.tanPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.8))
                .clipShape(Capsule())

            Text("找一找还在街边的老手艺")
                .font(.system(size: 25, weight: .black))
                .foregroundStyle(Color.tanInk)

            Text("小吃、修补、非遗体验，都藏在城市角落里。")
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
            Text("大家在找")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.tanInk.opacity(0.62))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(hotKeywords, id: \.self) { keyword in
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
                ForEach(ArchiveCategory.allCases, id: \.self) { category in
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
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: selectedCategory)
    }

    private func count(for category: ArchiveCategory) -> Int {
        store.archives.filter { $0.category == category }.count
    }
}
