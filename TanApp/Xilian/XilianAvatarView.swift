import SwiftUI
import UIKit

struct XilianAvatarView: View {
    enum Size {
        case small
        case medium
        case large

        var dimension: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 56
            case .large: return 88
            }
        }
    }

    var size: Size = .medium

    var body: some View {
        Group {
            if let avatar = UIImage(named: "xilian_avatar") {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .padding(size.dimension * 0.25)
                    .foregroundStyle(Color(red: 0.63, green: 0.43, blue: 0.72))
                    .background(Color(red: 0.98, green: 0.91, blue: 0.94))
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(Color.white.opacity(0.92), lineWidth: 2)
        }
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .accessibilityLabel("昔涟")
    }
}
