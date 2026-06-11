import SwiftUI

struct XilianFloatingButton: View {
    var state: XilianAnimationState = .idle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                XilianAnimatedAvatarView(state: state, size: .small)
                VStack(alignment: .leading, spacing: 1) {
                    Text("昔涟")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.tanInk)
                    Text("记忆向导")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.tanInk.opacity(0.52))
                }
            }
            .padding(.vertical, 7)
            .padding(.leading, 7)
            .padding(.trailing, 12)
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.84))
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(Color.white.opacity(0.9))
            }
            .shadow(color: Color.tanInk.opacity(0.14), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(XilianPressStyle())
        .accessibilityLabel("打开昔涟记忆向导")
    }
}

private struct XilianPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.84 : 1)
            .animation(.easeInOut(duration: 0.16), value: configuration.isPressed)
    }
}
