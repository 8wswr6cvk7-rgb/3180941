//
//  ReusableViews.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI

struct ArchiveRow: View {
    let archive: CityArchive

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(archive.status.tint.opacity(0.18))
                Image(systemName: archive.category.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(archive.status.tint)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 6) {
                Text(archive.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.tanInk)
                Text("\(archive.category.title) · \(archive.yearsActive) 年 · \(archive.priceOrService)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()
            StatusBadge(status: archive.status)
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.tanLine)
        }
    }
}

struct PhotoPlaceholder: View {
    let caption: String

    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.18))
            .overlay(alignment: .bottomLeading) {
                Text(caption)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.tanInk)
                    .lineLimit(2)
                    .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct EmptyStateView: View {
    let text: String

    var body: some View {
        Surface {
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
    }
}

struct FixedTabBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.white, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.light, for: .tabBar)
    }
}

extension View {
    func fixedWhiteTabBar() -> some View {
        modifier(FixedTabBackground())
    }
}
