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
                searchBar
                categoryTabs

                Text("市井档案 + 老手艺 / 非遗")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.tanInk)

                ForEach(archives) { archive in
                    NavigationLink(value: archive.id) {
                        ArchiveRow(archive: archive)
                    }
                    .buttonStyle(.plain)
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

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("搜索非遗、老行当、小吃、地点", text: $query)
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.tanLine)
        }
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedCategory = nil
                } label: {
                    TagPill(text: "全部", isSelected: selectedCategory == nil)
                }
                ForEach(ArchiveCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Label(category.title, systemImage: category.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selectedCategory == category ? .white : Color.tanInk)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.tanPrimary : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
