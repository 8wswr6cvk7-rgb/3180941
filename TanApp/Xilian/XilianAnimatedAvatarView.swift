import SwiftUI

enum XilianAnimationState: Hashable {
    case idle
    case thinking
    case speaking
    case happy
    case worried
}

struct XilianAnimatedAvatarView: View {
    let state: XilianAnimationState
    var size: XilianAvatarView.Size = .medium

    var body: some View {
        XilianAnimationBody(state: state, size: size)
            .id(state)
    }
}

private struct XilianAnimationBody: View {
    let state: XilianAnimationState
    let size: XilianAvatarView.Size

    @State private var animated = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(glowColor.opacity(animated ? 0.18 : 0.05))
                .frame(width: size.dimension + 8, height: size.dimension + 8)
                .blur(radius: animated ? 5 : 2)

            XilianAvatarView(size: size)
                .scaleEffect(animated ? animatedScale : baseScale)
                .offset(y: animated ? animatedOffset : baseOffset)
                .rotationEffect(.degrees(animated ? animatedRotation : baseRotation))
                .shadow(
                    color: glowColor.opacity(animated ? 0.34 : 0.12),
                    radius: animated ? 11 : 5,
                    x: 0,
                    y: 4
                )

            if state == .thinking {
                ProgressView()
                    .controlSize(.mini)
                    .tint(Color.tanPrimary)
                    .padding(5)
                    .background(Color.white.opacity(0.96))
                    .clipShape(Circle())
                    .offset(x: 2, y: 2)
            } else if state == .happy || state == .speaking {
                Image(systemName: "sparkles")
                    .font(.system(size: size == .small ? 10 : 13, weight: .bold))
                    .foregroundStyle(Color.tanPrimary)
                    .offset(x: 2, y: 2)
                    .opacity(animated ? 1 : 0.45)
            }
        }
        .frame(width: size.dimension + 10, height: size.dimension + 10)
        .onAppear {
            withAnimation(animation) {
                animated = true
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var animation: Animation {
        switch state {
        case .idle:
            return .easeInOut(duration: 2.6).repeatForever(autoreverses: true)
        case .thinking:
            return .easeInOut(duration: 0.7).repeatForever(autoreverses: true)
        case .speaking:
            return .easeInOut(duration: 0.42).repeatForever(autoreverses: true)
        case .happy:
            return .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
        case .worried:
            return .easeInOut(duration: 0.68).repeatForever(autoreverses: true)
        }
    }

    private var baseScale: CGFloat {
        state == .happy ? 1 : 0.99
    }

    private var animatedScale: CGFloat {
        switch state {
        case .idle: return 1.03
        case .thinking: return 1.02
        case .speaking: return 1.06
        case .happy: return 1.08
        case .worried: return 1.01
        }
    }

    private var baseOffset: CGFloat {
        switch state {
        case .idle, .speaking, .happy: return 2
        case .thinking, .worried: return 0
        }
    }

    private var animatedOffset: CGFloat {
        switch state {
        case .idle: return -3
        case .speaking: return -2
        case .happy: return -4
        case .thinking, .worried: return 0
        }
    }

    private var baseRotation: Double {
        switch state {
        case .thinking: return -2
        case .worried: return -2.5
        default: return 0
        }
    }

    private var animatedRotation: Double {
        switch state {
        case .thinking: return 2
        case .worried: return 2.5
        default: return 0
        }
    }

    private var glowColor: Color {
        switch state {
        case .worried: return .warningRed
        case .happy, .speaking: return .tanPrimary
        case .thinking: return Color(red: 0.63, green: 0.43, blue: 0.72)
        case .idle: return Color(red: 0.88, green: 0.63, blue: 0.77)
        }
    }

    private var accessibilityLabel: String {
        switch state {
        case .idle: return "昔涟正在陪伴"
        case .thinking: return "昔涟正在整理记忆"
        case .speaking: return "昔涟正在回答"
        case .happy: return "昔涟很开心"
        case .worried: return "昔涟正在担心这份档案"
        }
    }
}
