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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                        .fill(archive.status.tint.opacity(0.13))
                    Image(systemName: archive.category.icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(archive.status.tint)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 6) {
                    Text(archive.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.tanInk)
                    Text("\(archive.ownerName) · \(archive.category.title)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()
                StatusBadge(status: archive.status)
            }

            Text(archive.summary)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .lineLimit(2)

            HStack(spacing: 8) {
                Label("\(archive.yearsActive) 年", systemImage: "clock.fill")
                Text(archive.priceOrService)
                Spacer()
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Color.tanInk.opacity(0.72))
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.tanLine)
        }
        .shadow(color: Color.tanInk.opacity(0.06), radius: 12, x: 0, y: 7)
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
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
    }
}

struct EmptyStateView: View {
    let text: String

    var body: some View {
        Surface {
            VStack(spacing: 10) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.heritageGreen)
                    .frame(width: 48, height: 48)
                    .background(Color.heritageGreen.opacity(0.12))
                    .clipShape(Circle())
                Text(text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.tanInk.opacity(0.72))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
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

    func chineseFriendlyInput() -> some View {
        self
            .keyboardType(.default)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
    }
}
