//
//  AIArchiveBuilderView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI
import AVFoundation
import UIKit

struct AIArchiveBuilderView: View {
    @EnvironmentObject private var store: ArchiveStore
    @Environment(\.dismiss) private var dismiss
    private let qwenAgent = QwenArchiveAgent()

    var editingArchive: CityArchive? = nil

    @State private var messages: [BuilderMessage] = [
        BuilderMessage(role: "AI 建档助手", text: "先告诉我：这个摊或手艺叫什么？做了多少年？最值得记录的工序是哪一步？")
    ]
    @State private var input = ""
    @State private var isThinking = false
    @State private var isSavingDraft = false
    @State private var hasGeneratedDraft = false
    @State private var dialect: ArchiveDialect = .chengdu
    @State private var showExamplePrompt = true
    @State private var pendingImages: [PendingImage] = []
    @State private var toastMessage: String?
    @StateObject private var speechReader = SpeechReader()
    @StateObject private var speechController: SpeechRecognitionController
    @State private var showMicrophoneSettingsAlert = false
    @State private var draft = AIArchiveDraft(
        name: "未命名档案",
        ownerName: "摊主",
        category: .heritageCraft,
        tags: ["非遗档案", "可体验"],
        priceOrService: "待补充",
        yearsActive: 1,
        summary: "等待摊主补充故事，AI 将自动整理成档案摘要。",
        craftProcess: ["采集口述", "整理工序", "等待用户反馈补档"]
    )

    init(
        editingArchive: CityArchive? = nil,
        speechService: SpeechRecognitionService = DashScopeSpeechRecognitionService()
    ) {
        self.editingArchive = editingArchive
        _speechController = StateObject(
            wrappedValue: SpeechRecognitionController(service: speechService)
        )
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 14) {
                        buildSteps
                        if showExamplePrompt {
                            examplePromptCard
                        }
                        ownerBanner
                        archivePhotoCard
                        conversation
                        quickPromptChips
                        draftCard
                    }
                    .frame(width: max(proxy.size.width - 32, 0), alignment: .leading)
                    .padding(16)
                }
                .background(Color.tanPaper)

                composer
                    .frame(width: proxy.size.width)
                    .background(.white)
            }
        }
        .background(Color.tanPaper)
        .toastOverlay(toastMessage)
        .navigationTitle("AI 建档")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let editingArchive {
                draft = AIArchiveDraft(archive: editingArchive)
                hasGeneratedDraft = true
                messages = [
                    BuilderMessage(role: "AI 建档助手", text: "我已载入原档案。你可以直接说“把营业时间改成下午三点后”，或补充新的故事、路线、工序。")
                ]
            }
            speakLatestAIQuestion()
        }
        .onChange(of: speechController.completion?.id) { _ in
            guard let completion = speechController.completion else { return }
            input = SpeechTranscriptMerger.merge(existing: input, transcript: completion.text)
            speechController.consumeCompletion()
        }
        .onChange(of: speechController.failure) { failure in
            showMicrophoneSettingsAlert = failure?.offersSettings == true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            speechController.cancel(preservingTranscript: true)
        }
        .onDisappear {
            speechController.cancel()
            speechReader.stop()
        }
        .alert("无法使用麦克风", isPresented: $showMicrophoneSettingsAlert) {
            Button("取消", role: .cancel) {}
            Button("前往设置") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
        } message: {
            Text("请在系统设置中允许“摊”使用麦克风。你也可以取消并继续使用键盘输入。")
        }
    }

    private var archivePhotoCard: some View {
        Surface {
            Text("摊位现场照片")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(Color.tanInk)
            Text("照片会作为档案封面与补充材料保存；当前 AI 只根据你的文字整理档案。")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineSpacing(3)
            ImageAttachmentPicker(
                pendingImages: $pendingImages,
                maximumSelectionCount: 1,
                emptyPrompt: "可拍摄或从相册选择 1 张摊位照片"
            )
        }
    }

    private var buildSteps: some View {
        Surface {
            Text("拍一张现场照片，再讲讲摊位故事；AI 会根据文字整理成档案。")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.tanInk)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                ArchiveBuildStep(number: "1", title: "拍摄与口述", isHighlighted: !isThinking && !hasGeneratedDraft)
                Rectangle()
                    .fill(Color.tanLine)
                    .frame(height: 2)
                ArchiveBuildStep(number: "2", title: "整理", isHighlighted: isThinking)
                Rectangle()
                    .fill(Color.tanLine)
                    .frame(height: 2)
                ArchiveBuildStep(number: "3", title: "确认入库", isHighlighted: hasGeneratedDraft && !isThinking)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var ownerBanner: some View {
        Surface {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.tanPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text("摊户 AI 建档助手")
                        .font(.system(size: 22, weight: .black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    Text("慢慢说，AI 会追问、整理，再生成一张能入库的摊档名片。")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Button {
                    speakLatestAIQuestion()
                } label: {
                    Label("普通话朗读", systemImage: "speaker.wave.2.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                        .padding(.horizontal, 11)
                        .frame(height: 34)
                        .background(Color.mutedOrange.opacity(0.6))
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var examplePromptCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "quote.bubble.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.tanPrimary)
                .frame(width: 34, height: 34)
                .background(Color.mutedOrange.opacity(0.65))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text("不知道怎么开始？")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(Color.tanInk)
                Text("你可以这样说：我是王嬢嬢，在玉林路卖糖油果子，做了二十多年，老顾客都喜欢下午来。")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.tanInk.opacity(0.68))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    showExamplePrompt = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(Color.tanInk.opacity(0.52))
                    .frame(width: 28, height: 28)
                    .background(.white.opacity(0.7))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.mutedOrange.opacity(0.38))
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                .stroke(Color.white.opacity(0.82))
        }
    }

    private var conversation: some View {
        VStack(spacing: 10) {
            ForEach(messages) { message in
                HStack(alignment: .bottom, spacing: 8) {
                    if message.role == "摊户" {
                        Spacer(minLength: 40)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.role)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(message.role == "摊户" ? .white.opacity(0.78) : Color.tanInk.opacity(0.55))
                        Text(message.text)
                            .font(.system(size: 15))
                            .foregroundStyle(message.role == "摊户" ? .white : Color.tanInk)
                            .lineSpacing(3)
                    }
                    .padding(14)
                    .frame(maxWidth: 260, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(message.role == "摊户" ? Color.tanPrimary : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color.tanInk.opacity(0.05), radius: 8, x: 0, y: 5)
                    if message.role != "摊户" {
                        Button {
                            speechReader.speak(message.text)
                        } label: {
                            Image(systemName: "speaker.wave.2")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.tanPrimary)
                                .frame(width: 32, height: 32)
                                .background(.white)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("使用普通话朗读")
                        Spacer(minLength: 40)
                    }
                }
                .frame(maxWidth: .infinity, alignment: message.role == "摊户" ? .trailing : .leading)
            }

            if isThinking {
                AIProcessCard()
            }
        }
    }

    private var quickPromptChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("可以先从这些说起")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.tanInk.opacity(0.62))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickPrompts, id: \.self) { prompt in
                        Button {
                            input = prompt
                        } label: {
                            Text(prompt)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.tanPrimary)
                                .padding(.horizontal, 12)
                                .frame(height: 34)
                                .background(.white)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule().stroke(Color.tanLine)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 2)
    }

    private var quickPrompts: [String] {
        ["我做什么手艺？", "常在哪出摊？", "做了多少年？", "有什么街坊故事？", "参考价格大概多少？"]
    }

    private var draftCard: some View {
        Surface {
            HStack(spacing: 12) {
                DraftAvatarView(category: draft.category)

                VStack(alignment: .leading, spacing: 5) {
                    Text("AI 生成档案")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color.tanPrimary)
                    Text(draft.name)
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(Color.tanInk)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(draft.summary)
                .font(.system(size: 14))
                .foregroundStyle(Color.tanInk.opacity(0.68))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            FlowTags(tags: draft.tags)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    InfoChip(text: "\(draft.ownerName)")
                    InfoChip(text: draft.category.title)
                    InfoChip(text: "\(draft.yearsActive) 年")
                    InfoChip(text: draft.priceOrService)
                }
            }

            Button {
                saveCurrentDraft()
            } label: {
                Text(isSavingDraft ? "正在保存…" : (editingArchive == nil ? "确认入库" : "保存修改"))
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isSavingDraft || isThinking || !hasGeneratedDraft)
        }
    }

    private var composer: some View {
        VStack(spacing: 9) {
            HStack(spacing: 10) {
                Menu {
                    ForEach(ArchiveDialect.allCases, id: \.self) { item in
                        Button {
                            dialect = item
                        } label: {
                            Label(item.title, systemImage: dialect == item ? "checkmark.circle.fill" : "waveform")
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform")
                            .font(.system(size: 15, weight: .bold))
                        Text(dialect.title)
                            .font(.system(size: 14, weight: .black))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(Color.tanPrimary)
                    .padding(.horizontal, 12)
                    .frame(height: 38)
                    .background(Color.tanPrimary.opacity(0.12))
                    .clipShape(Capsule())
                }
                .disabled(speechController.state.isBusy)
                .accessibilityIdentifier("archive.dialect.selector")

                Text(dialect.recognitionNote)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.tanInk.opacity(0.58))
                    .lineLimit(1)

                Spacer(minLength: 0)

                Button {
                    if speechController.isRecording || speechController.state == .connecting {
                        speechController.stop()
                    } else {
                        speechController.start(dialect: dialect)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: speechController.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 14, weight: .black))
                        Text(speechController.isRecording ? "停止" : "开始口述")
                            .font(.system(size: 12, weight: .black))
                    }
                    .foregroundStyle(speechController.isRecording ? .white : Color.tanPrimary)
                    .padding(.horizontal, 12)
                    .frame(height: 38)
                    .background(speechController.isRecording ? Color.warningRed : Color.mutedOrange.opacity(0.62))
                    .clipShape(Capsule())
                }
                .disabled(
                    isThinking
                    || speechController.state == .requestingPermission
                    || speechController.state == .finalizing
                )
                .accessibilityLabel(speechController.isRecording ? "停止语音输入" : "开始语音输入")
                .accessibilityIdentifier("archive.speech.toggle")
            }

            if speechController.state.isBusy
                || speechController.state == .failed
                || !speechController.liveTranscript.isEmpty {
                speechRecognitionStatus
            }

            HStack(spacing: 10) {
                ChineseFriendlyTextField(placeholder: "回答 AI 的问题，或说“修改为...”", text: $input)
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.tanPaper)
                    .clipShape(Capsule())
                    .layoutPriority(1)
                    .allowsHitTesting(!speechController.state.isBusy)
                    .opacity(speechController.state.isBusy ? 0.68 : 1)

                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Color.tanPrimary.opacity(
                                input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                || isThinking
                                || speechController.state.isBusy ? 0.4 : 1
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.tanPrimary.opacity(0.2), radius: 10, x: 0, y: 6)
                }
                .disabled(
                    input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || isThinking
                    || speechController.state.isBusy
                )
                .accessibilityLabel("发送建档讲述")
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.tanLine)
                .frame(height: 1)
        }
    }

    private var speechRecognitionStatus: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                if speechController.state == .listening {
                    Circle()
                        .fill(Color.warningRed)
                        .frame(width: 8, height: 8)
                } else if speechController.state == .requestingPermission
                            || speechController.state == .connecting
                            || speechController.state == .finalizing {
                    ProgressView()
                        .scaleEffect(0.75)
                        .frame(width: 14, height: 14)
                } else {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.warningRed)
                }

                Text(speechController.statusText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(
                        speechController.state == .failed
                        ? Color.warningRed
                        : Color.tanInk.opacity(0.72)
                    )
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                if speechController.failure?.offersSettings == true {
                    Button("前往设置") {
                        showMicrophoneSettingsAlert = true
                    }
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(Color.tanPrimary)
                }
            }

            if !speechController.liveTranscript.isEmpty {
                Text(speechController.liveTranscript)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.tanInk)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("实时转写：\(speechController.liveTranscript)")
            } else if speechController.state == .listening {
                Text("请开始讲述，识别文字会实时出现在这里。")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tanPaper)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.small, style: .continuous))
        .accessibilityIdentifier("archive.speech.status")
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !speechController.state.isBusy else { return }
        messages.append(BuilderMessage(role: "摊户", text: text))
        input = ""
        isThinking = true

        Task {
            await applyQwenAgentUpdate(from: "建档语言：\(dialect.title)。\(text)")
        }
    }

    private func saveCurrentDraft() {
        guard !isSavingDraft else { return }
        isSavingDraft = true
        let image = pendingImages.first
        Task {
            do {
                if let editingArchive {
                    store.updateArchive(editingArchive, with: draft)
                    if let image {
                        try await store.addPhoto(to: editingArchive, caption: "摊主更新现场照片", pendingImage: image)
                    }
                    showToast("档案修改已保存", binding: $toastMessage)
                } else {
                    try await store.saveDraft(draft, coverImage: image)
                    showToast("档案已入库，可以在地图上看到它了", binding: $toastMessage)
                }
                try? await Task.sleep(nanoseconds: 650_000_000)
                dismiss()
            } catch {
                showToast("图片保存失败，请重试或继续只提交文字档案。", binding: $toastMessage)
                isSavingDraft = false
            }
        }
    }

    @MainActor
    private func applyQwenAgentUpdate(from text: String) async {
        do {
            let result = try await qwenAgent.refineDraft(
                currentDraft: draft,
                userText: text,
                userName: store.user.name
            )
            draft = result.draft
            appendAIMessage("千问已更新档案草稿。\(result.nextQuestion)")
        } catch {
            applyLocalAgentUpdate(from: text)
            appendAIMessage("暂时无法连接，已根据当前讲述生成可继续修改的草稿。下一步可以补充常出现的位置、是否带徒，以及最怕失传的细节。")
        }
        hasGeneratedDraft = true
        isThinking = false
    }

    private func applyLocalAgentUpdate(from text: String) {
        if text.contains("补鞋") || text.contains("缝衣") || text.contains("修") {
            draft.category = .oldTrade
            draft.tags = ["老行当", "高消失风险", "服务清单"]
        } else if text.contains("糖画") || text.contains("蜀锦") || text.contains("皮影") || text.contains("扎染") {
            draft.category = .heritageCraft
            draft.tags = ["非遗档案", "可体验", "传承人"]
        } else if text.contains("豆腐") || text.contains("糍粑") || text.contains("叶儿粑") || text.contains("吃") {
            draft.category = .snack
            draft.tags = ["饮食手艺", "工序故事"]
        }

        let pieces = text.split(separator: "，").map(String.init)
        if let first = pieces.first, first.count < 18 {
            draft.name = first
        }
        draft.ownerName = store.user.name
        draft.summary = "根据摊户口述整理：\(text)。保存前仍可继续核对和修改。"
        draft.craftProcess = ["口述采集", "信息梳理", "工序确认", "社区补档"]
    }

    private func appendAIMessage(_ text: String) {
        messages.append(BuilderMessage(role: "AI 建档助手", text: text))
        speechReader.speak(text)
    }

    private func speakLatestAIQuestion() {
        guard let text = messages.last(where: { $0.role == "AI 建档助手" })?.text else {
            return
        }
        speechReader.speak(text)
    }
}

private struct BuilderMessage: Identifiable {
    let id = UUID()
    let role: String
    let text: String
}

private struct ArchiveBuildStep: View {
    let number: String
    let title: String
    let isHighlighted: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(number)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(isHighlighted ? .white : Color.tanInk.opacity(0.64))
                .frame(width: 30, height: 30)
                .background(isHighlighted ? Color.tanPrimary : Color.tanPaper)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(isHighlighted ? Color.tanPrimary.opacity(0.5) : Color.tanLine)
                }
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isHighlighted ? Color.tanPrimary : Color.tanInk.opacity(0.58))
        }
    }
}

private struct AIProcessCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("正在整理档案…")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(Color.tanInk)

            AIProcessRow(icon: "checkmark.circle.fill", text: "识别口述内容", isLoading: false)
            AIProcessRow(icon: "checkmark.circle.fill", text: "提取摊位信息", isLoading: false)
            AIProcessRow(icon: "sparkles", text: "生成档案卡片", isLoading: true)
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                .stroke(Color.tanLine)
        }
        .shadow(color: Color.tanInk.opacity(0.05), radius: 10, x: 0, y: 6)
    }
}

private struct AIProcessRow: View {
    let icon: String
    let text: String
    let isLoading: Bool

    var body: some View {
        HStack(spacing: 10) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.78)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.heritageGreen)
                    .frame(width: 20, height: 20)
            }
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.tanInk.opacity(0.7))
            Spacer()
        }
    }
}

private struct InfoChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Color.tanInk.opacity(0.72))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(Color.tanPaper)
            .clipShape(Capsule())
    }
}

private struct DraftAvatarView: View {
    let category: ArchiveCategory

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.tanPrimary.opacity(0.22), Color.heritageGreen.opacity(0.16), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: category.icon)
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(Color.tanPrimary)
        }
        .frame(width: 58, height: 58)
        .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                .stroke(Color.white.opacity(0.82))
        }
        .accessibilityLabel("\(category.title)档案类别图标")
    }
}

private struct FlowTags: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    TagPill(text: tag)
                }
            }
        }
    }
}

private final class SpeechReader: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
