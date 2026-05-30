//
//  DesignSystem.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import SwiftUI
import UIKit

extension Color {
    static let tanPrimary = Color(hex: 0xFF6B35)
    static let tanSecondary = Color(hex: 0x2D2D2D)
    static let tanBackground = Color(hex: 0xF5F5F0)

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension StallStatus {
    var tintColor: Color {
        switch self {
        case .open:
            return .green
        case .closed:
            return .orange
        case .gone:
            return .gray
        }
    }

    var mapUIColor: UIColor {
        switch self {
        case .open:
            return .systemGreen
        case .closed:
            return .systemOrange
        case .gone:
            return .systemGray
        }
    }
}

struct StatusBadge: View {
    let status: StallStatus

    var body: some View {
        Text(status.title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(status.tintColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(status.tintColor.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct SectionCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
}
