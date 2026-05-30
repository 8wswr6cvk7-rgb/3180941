//
//  DiscoverView.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var appModel: TanAppModel

    @State private var searchText = ""
    @State private var selectedCategory = "全部"

    private let categories = ["全部", "小吃", "蔬菜", "水果", "其他"]

    private var filteredStalls: [Stall] {
        appModel.searchStalls(query: searchText, category: selectedCategory)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                searchBar

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Text(category)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(selectedCategory == category ? .white : Color.tanSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedCategory == category ? Color.tanPrimary : .white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }

                LazyVStack(spacing: 12) {
                    ForEach(filteredStalls) { stall in
                        NavigationLink {
                            StallDetailView(stall: stall)
                        } label: {
                            DiscoverRow(stall: stall)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .background(Color.tanBackground.ignoresSafeArea())
        .navigationTitle("发现")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("搜索摊位、摊主、品类或故事", text: $searchText)
                .font(.system(size: 15))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct DiscoverRow: View {
    let stall: Stall

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.gray.opacity(0.6))
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(stall.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.tanSecondary)

                Text("\(stall.category) · 已摆摊 \(stall.yearsActive) 年")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusBadge(status: stall.status)
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiscoverView()
                .environmentObject(TanAppModel())
        }
    }
}
