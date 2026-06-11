import SwiftUI

struct XilianChatView: View {
    @Environment(\.dismiss) private var dismiss

    let selectedArchive: CityArchive?
    let nearbyArchives: [CityArchive]
    var onOpenArchive: ((CityArchive) -> Void)?

    @StateObject private var viewModel: XilianChatViewModel

    init(
        selectedArchive: CityArchive?,
        nearbyArchives: [CityArchive],
        currentPage: XilianCurrentPage = .map,
        onOpenArchive: ((CityArchive) -> Void)? = nil
    ) {
        self.selectedArchive = selectedArchive
        self.nearbyArchives = nearbyArchives
        self.onOpenArchive = onOpenArchive
        _viewModel = StateObject(
            wrappedValue: XilianChatViewModel(
                selectedArchive: selectedArchive,
                nearbyArchives: nearbyArchives,
                currentPage: currentPage
            )
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                conversation
                composer
            }
            .background(Color.tanPaper.ignoresSafeArea())
            .navigationTitle("昔涟")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Color.tanInk)
                            .frame(width: 34, height: 34)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("关闭昔涟")
                }
            }
        }
    }

    private var conversation: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    introduction
                    if let selectedArchive {
                        selectedArchiveHint(selectedArchive)
                    }
                    quickQuestions

                    ForEach(viewModel.messages) { message in
                        XilianMessageBubble(message: message)
                            .id(message.id)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if viewModel.isThinking {
                        thinkingRow
                            .id("xilian-thinking")
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }

                    if let selectedArchive,
                       viewModel.selectedQuickQuestion == .story {
                        Button {
                            onOpenArchive?(selectedArchive)
                            dismiss()
                        } label: {
                            Label("打开这份档案", systemImage: "doc.text.magnifyingglass")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .padding(18)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) { _, _ in
                guard let lastID = viewModel.messages.last?.id else { return }
                withAnimation(.easeOut(duration: 0.24)) {
                    proxy.scrollTo(lastID, anchor: .bottom)
                }
            }
            .onChange(of: viewModel.isThinking) { _, isThinking in
                guard isThinking else { return }
                withAnimation(.easeOut(duration: 0.24)) {
                    proxy.scrollTo("xilian-thinking", anchor: .bottom)
                }
            }
        }
    }

    private var introduction: some View {
        HStack(spacing: 14) {
            XilianAnimatedAvatarView(state: viewModel.animationState, size: .large)
            VStack(alignment: .leading, spacing: 6) {
                Text("城市记忆向导")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(Color.tanPrimary)
                Text("昔涟")
                    .font(.system(size: 25, weight: .black))
                    .foregroundStyle(Color.tanInk)
                Text(viewModel.isThinking ? "正在整理街巷里的记忆…" : "陪伙伴寻找街巷里的旧记忆")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .contentTransition(.opacity)
            }
            Spacer()
        }
        .padding(16)
        .background {
            LinearGradient(
                colors: [Color(red: 1, green: 0.91, blue: 0.94), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.large, style: .continuous)
                .stroke(Color.white.opacity(0.9))
        }
        .shadow(color: Color.tanInk.opacity(0.07), radius: 16, x: 0, y: 9)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isThinking)
    }

    private func selectedArchiveHint(_ archive: CityArchive) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前摊位小提示")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(Color.tanPrimary)
                    Text(archive.name)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(Color.tanInk)
                }
                Spacer()
                StatusBadge(status: archive.status)
            }
            Text(XilianCopy.statusHint(for: archive))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.tanInk.opacity(0.68))
                .lineSpacing(4)
        }
        .padding(15)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                .stroke(Color.tanLine)
        }
    }

    private var quickQuestions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("想从哪里开始？")
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(Color.tanInk)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(XilianQuickQuestion.allCases) { question in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.askQuickQuestion(question)
                            }
                        } label: {
                            Text(question.rawValue)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(viewModel.selectedQuickQuestion == question ? .white : Color.tanInk)
                                .padding(.horizontal, 13)
                                .frame(height: 38)
                                .background(viewModel.selectedQuickQuestion == question ? Color.tanPrimary : Color.white)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule().stroke(
                                        viewModel.selectedQuickQuestion == question ? Color.clear : Color.tanLine
                                    )
                                }
                        }
                        .buttonStyle(XilianChipButtonStyle())
                        .disabled(viewModel.isThinking)
                    }
                }
            }
        }
    }

    private var thinkingRow: some View {
        HStack(spacing: 10) {
            XilianAnimatedAvatarView(state: .thinking, size: .small)
            HStack(spacing: 9) {
                ProgressView()
                    .controlSize(.small)
                    .tint(Color.tanPrimary)
                Text("昔涟正在整理记忆…")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.tanInk.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Color.white.opacity(0.9))
            .clipShape(Capsule())
            Spacer()
        }
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("问昔涟一个问题…", text: $viewModel.inputText, axis: .vertical)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.tanInk)
                .lineLimit(1...4)
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(Color.tanPaper.opacity(0.78))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.tanLine)
                }
                .submitLabel(.send)
                .onSubmit {
                    viewModel.send()
                }

            Button {
                viewModel.send()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.tanPrimary.opacity(viewModel.canSend ? 1 : 0.38))
                    .clipShape(Circle())
                    .shadow(color: Color.tanPrimary.opacity(0.2), radius: 9, x: 0, y: 5)
            }
            .disabled(!viewModel.canSend)
            .accessibilityLabel("发送给昔涟")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.tanLine.opacity(0.7))
                .frame(height: 1)
        }
    }
}

private struct XilianChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.easeInOut(duration: 0.14), value: configuration.isPressed)
    }
}
