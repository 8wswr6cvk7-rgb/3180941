import SwiftUI

struct XilianMapAnnotationView: View {
    static let spriteWidth: CGFloat = 54
    static let spriteHeight: CGFloat = 58
    static let bottomTransparentPadding: CGFloat = 1

    let message: String
    let state: XilianAnimationState

    var body: some View {
        ZStack {
            XilianMapSpriteView(
                state: state,
                width: Self.spriteWidth,
                height: Self.spriteHeight,
                keepsRouteAnchor: true
            )

            #if DEBUG
            Circle()
                .fill(Color.blue)
                .frame(width: 5, height: 5)
                .position(
                    x: Self.spriteWidth / 2,
                    y: Self.spriteHeight - Self.bottomTransparentPadding
                )
            #endif
        }
        .frame(width: Self.spriteWidth, height: Self.spriteHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message.isEmpty ? "昔涟在地图上" : "昔涟地图提示：\(message)")
    }
}
