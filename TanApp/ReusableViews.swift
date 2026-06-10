//
//  ReusableViews.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI
import UIKit

struct ArchiveRow: View {
    let archive: CityArchive

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                        .fill(archive.status.tint.opacity(0.13))
                    Image(systemName: archive.category.icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(archive.status.tint)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 6) {
                    Text(archive.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.tanInk)
                    Text("\(archive.ownerName) · \(archive.category.title)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()
                StatusBadge(status: archive.status)
            }

            Text(archive.summary)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .lineLimit(2)

            HStack(spacing: 8) {
                Label("\(archive.yearsActive) 年", systemImage: "clock.fill")
                Text(archive.priceOrService)
                Spacer()
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Color.tanInk.opacity(0.72))
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.tanLine)
        }
        .shadow(color: Color.tanInk.opacity(0.06), radius: 12, x: 0, y: 7)
    }
}

struct PhotoPlaceholder: View {
    let caption: String

    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.18))
            .overlay(alignment: .bottomLeading) {
                Text(caption)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.tanInk)
                    .lineLimit(2)
                    .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
    }
}

struct EmptyStateView: View {
    let text: String
    var icon: String = "leaf.fill"

    var body: some View {
        Surface {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.heritageGreen)
                    .frame(width: 48, height: 48)
                    .background(Color.heritageGreen.opacity(0.12))
                    .clipShape(Circle())
                Text(text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.tanInk.opacity(0.72))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.78))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 8)
            .padding(.horizontal, 18)
    }
}

struct ToastOverlayModifier: ViewModifier {
    let message: String?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let message {
                    ToastView(message: message)
                        .padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(20)
                }
            }
    }
}

struct FixedTabBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.white, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.light, for: .tabBar)
    }
}

extension View {
    func fixedWhiteTabBar() -> some View {
        modifier(FixedTabBackground())
    }

    func toastOverlay(_ message: String?) -> some View {
        modifier(ToastOverlayModifier(message: message))
    }

    func chineseFriendlyInput() -> some View {
        self
            .keyboardType(.default)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
    }
}

@MainActor
func showToast(_ message: String, binding: Binding<String?>, duration: Double = 1.5) {
    withAnimation(.easeInOut(duration: 0.18)) {
        binding.wrappedValue = message
    }
    Task { @MainActor in
        let nanoseconds = UInt64(duration * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanoseconds)
        if binding.wrappedValue == message {
            withAnimation(.easeInOut(duration: 0.18)) {
                binding.wrappedValue = nil
            }
        }
    }
}

struct ChineseFriendlyTextField: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var font: UIFont = .systemFont(ofSize: 15, weight: .semibold)

    func makeUIView(context: Context) -> UITextField {
        let textField = ChinesePreferredUITextField()
        textField.placeholder = placeholder
        textField.font = font
        textField.textColor = UIColor(Color.tanInk)
        textField.tintColor = UIColor(Color.tanPrimary)
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.placeholder = placeholder
        uiView.font = font
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        @objc func textChanged(_ sender: UITextField) {
            text = sender.text ?? ""
        }
    }
}

private final class ChinesePreferredUITextField: UITextField {
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: super.intrinsicContentSize.height)
    }

    override var textInputMode: UITextInputMode? {
        UITextInputMode.activeInputModes.first { mode in
            guard let language = mode.primaryLanguage else {
                return false
            }
            return language == "zh-Hans" || language.hasPrefix("zh")
        } ?? super.textInputMode
    }
}
