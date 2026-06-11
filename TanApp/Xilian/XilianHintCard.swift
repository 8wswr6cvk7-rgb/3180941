import SwiftUI

struct XilianHintCard: View {
    let archive: CityArchive

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            XilianAnimatedAvatarView(
                state: archive.status == .atRisk ? .worried : .idle,
                size: .small
            )
            VStack(alignment: .leading, spacing: 5) {
                Text("昔涟提示")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color.tanInk)
                Text(XilianCopy.detailHint(for: archive))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.tanInk.opacity(0.68))
                    .lineSpacing(3)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                .stroke(Color(red: 0.89, green: 0.80, blue: 0.89).opacity(0.72))
        }
        .shadow(color: Color.tanInk.opacity(0.06), radius: 12, x: 0, y: 7)
    }
}
