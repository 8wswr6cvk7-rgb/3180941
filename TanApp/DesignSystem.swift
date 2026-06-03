//
//  DesignSystem.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI
import UIKit

extension Color {
    static let tanPrimary = Color(hex: 0xFF6B35)
    static let tanInk = Color(hex: 0x2D2D2D)
    static let tanPaper = Color(hex: 0xF7F3EA)
    static let tanLine = Color.black.opacity(0.08)
    static let heritageGreen = Color(hex: 0x2F7D59)
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
            return .green
        case .closed:
            return .orange
        case .atRisk:
            return .gray
        }
    }

    var mapUIColor: UIColor {
        switch self {
        case .open:
            return .systemGreen
        case .closed:
            return .systemOrange
        case .atRisk:
            return .systemGray
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
        Text(status.title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(status.tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(status.tint.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct TagPill: View {
    let text: String
    var isSelected = false

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isSelected ? .white : Color.tanInk)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isSelected ? Color.tanPrimary : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.tanLine)
            }
    }
}

struct Surface<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.tanLine)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.tanPrimary.opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
