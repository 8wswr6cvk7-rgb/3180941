import SwiftUI
import UIKit

struct XilianMapSpriteView: View {
    let state: XilianAnimationState
    var width: CGFloat?
    var height: CGFloat = 66
    var keepsRouteAnchor = false

    @State private var animated = false

    var body: some View {
        sprite
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
            .scaleEffect(animated ? animatedScale : 1)
            .offset(x: animated ? animatedXOffset : 0, y: animated ? animatedYOffset : 0)
            .rotationEffect(.degrees(animated ? animatedRotation : 0))
            .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
            .onAppear {
                withAnimation(animation) {
                    animated = true
                }
            }
            .onChange(of: state) { _ in
                animated = false
                withAnimation(animation) {
                    animated = true
                }
            }
            .accessibilityLabel("昔涟地图向导")
    }

    private var sprite: Image {
        if let image = UIImage(named: "xilian_sprite") ?? UIImage(named: "xilian_avatar") {
            return Image(uiImage: image)
        }
        return Image(systemName: "sparkles")
    }

    private var animation: Animation {
        switch state {
        case .moving:
            return .easeInOut(duration: 0.48).repeatForever(autoreverses: true)
        case .happy:
            return .easeInOut(duration: 0.58).repeatForever(autoreverses: true)
        case .worried:
            return .easeInOut(duration: 0.72).repeatForever(autoreverses: true)
        default:
            return .easeInOut(duration: 2.4).repeatForever(autoreverses: true)
        }
    }

    private var animatedScale: CGFloat {
        guard !keepsRouteAnchor else { return 1 }

        switch state {
        case .moving:
            return 1.04
        case .happy:
            return 1.06
        default:
            return 1.02
        }
    }

    private var animatedXOffset: CGFloat {
        guard !keepsRouteAnchor else { return 0 }

        return state == .moving ? 2 : 0
    }

    private var animatedYOffset: CGFloat {
        guard !keepsRouteAnchor else { return 0 }

        switch state {
        case .moving:
            return -4
        case .happy:
            return -3
        default:
            return -2
        }
    }

    private var animatedRotation: Double {
        guard !keepsRouteAnchor else { return 0 }

        return state == .moving ? 3 : 0
    }
}
