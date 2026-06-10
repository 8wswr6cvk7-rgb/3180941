//
//  DesignSystem.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI
import UIKit

extension Color {
    static let tanPrimary = Color(hex: 0xF26A2E)
    static let tanInk = Color(hex: 0x33251E)
    static let tanPaper = Color(hex: 0xF7F1E6)
    static let tanLine = Color(hex: 0xE9DECE)
    static let heritageGreen = Color(hex: 0x6F9D72)
    static let warningRed = Color(hex: 0xC95B45)
    static let mutedOrange = Color(hex: 0xFFE3CF)
    static let craftBlue = Color(hex: 0x355C7D)

    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

enum TanRadius {
    static let small: CGFloat = 10
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xlarge: CGFloat = 28
}

extension ArchiveStatus {
    var title: String {
        switch self {
        case .open:
            return "营业中"
        case .closed:
            return "已收摊"
        case .atRisk:
            return "消失预警"
        }
    }

    var tint: Color {
        switch self {
        case .open:
            return .heritageGreen
        case .closed:
            return Color(hex: 0x8F877B)
        case .atRisk:
            return .warningRed
        }
    }

    var mapUIColor: UIColor {
        switch self {
        case .open:
            return UIColor(Color.heritageGreen)
        case .closed:
            return UIColor(Color(hex: 0x8F877B))
        case .atRisk:
            return UIColor(Color.warningRed)
        }
    }

    var icon: String {
        switch self {
        case .open:
            return "checkmark.circle.fill"
        case .closed:
            return "moon.zzz.fill"
        case .atRisk:
            return "exclamationmark.triangle.fill"
        }
    }
}

extension ArchiveCategory {
    var title: String {
        switch self {
        case .snack:
            return "小吃"
        case .produce:
            return "蔬果"
        case .heritageCraft:
            return "非遗手艺"
        case .oldTrade:
            return "老行当"
        case .cultureExperience:
            return "文化体验"
        case .other:
            return "其他"
        }
    }

    var icon: String {
        switch self {
        case .snack:
            return "takeoutbag.and.cup.and.straw.fill"
        case .produce:
            return "leaf.fill"
        case .heritageCraft:
            return "sparkles"
        case .oldTrade:
            return "wrench.and.screwdriver.fill"
        case .cultureExperience:
            return "paintpalette.fill"
        case .other:
            return "archivebox.fill"
        }
    }
}

struct StatusBadge: View {
    let status: ArchiveStatus

    var body: some View {
        Label(status.title, systemImage: status.icon)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(status.tint)
            .labelStyle(.titleAndIcon)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(status.tint.opacity(0.13))
            .clipShape(Capsule())
    }
}

struct TagPill: View {
    let text: String
    var isSelected = false

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isSelected ? .white : Color.tanInk)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.tanPrimary : Color.tanPaper)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(isSelected ? Color.tanPrimary.opacity(0.5) : Color.tanLine)
            }
            .shadow(color: isSelected ? Color.tanPrimary.opacity(0.16) : .clear, radius: 8, x: 0, y: 4)
    }
}

struct Surface<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                .stroke(Color.tanLine)
        }
        .shadow(color: Color.tanInk.opacity(0.07), radius: 14, x: 0, y: 8)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .padding(.horizontal, 18)
            .background(Color.tanPrimary.opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(Capsule())
            .shadow(color: Color.tanPrimary.opacity(configuration.isPressed ? 0.08 : 0.22), radius: 14, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.14), value: configuration.isPressed)
    }
}
