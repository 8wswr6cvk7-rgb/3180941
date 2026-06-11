import SwiftUI

struct XilianMessageBubble: View {
    let message: XilianChatMessage

    var body: some View {
        switch message.role {
        case .xilian:
            xilianBubble
        case .user:
            userBubble
        }
    }

    private var xilianBubble: some View {
        HStack(alignment: .top, spacing: 10) {
            XilianAvatarView(size: .small)
            Text(message.text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.tanInk)
                .lineSpacing(4)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background {
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.94, blue: 0.95), Color.tanPaper],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.tanLine.opacity(0.8))
                }
            Spacer(minLength: 26)
        }
    }

    private var userBubble: some View {
        HStack(alignment: .top) {
            Spacer(minLength: 42)
            Text(message.text)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .lineSpacing(4)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.tanPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.tanPrimary.opacity(0.16), radius: 8, x: 0, y: 5)
        }
    }
}
