//
//  AIArchiveBuilderView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI
import AVFoundation

struct AIArchiveBuilderView: View {
    @EnvironmentObject private var store: ArchiveStore
    @Environment(\.dismiss) private var dismiss
    private let qwenAgent = QwenArchiveAgent()

    var editingArchive: CityArchive? = nil

    @State private var messages: [BuilderMessage] = [
        BuilderMessage(role: "AI Agent", text: "先告诉我：这个摊或手艺叫什么？做了多少年？最值得记录的工序是哪一步？")
    ]
    @State private var input = ""
    @State private var isThinking = false
    @State private var dialect: ArchiveDialect = .chengdu
    @StateObject private var speechReader = SpeechReader()
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

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    buildSteps
                    ownerBanner
                    conversation
                    draftCard
                }
                .padding(16)
            }
            .background(Color.tanPaper)

            composer
                .background(.white)
        }
        .navigationTitle("AI 建档")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let editingArchive {
                draft = AIArchiveDraft(archive: editingArchive)
                messages = [
                    BuilderMessage(role: "AI Agent", text: "我已载入原档案。你可以直接说“把营业时间改成下午三点后”，或补充新的故事、路线、工序。")
                ]
            }
            speakLatestAIQuestion()
        }
    }

    private var buildSteps: some View {
        Surface {
            Text("说几句摊位故事，AI 会帮你整理成档案。")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.tanInk)

            HStack(spacing: 8) {
                ArchiveBuildStep(number: "1", title: "口述", isHighlighted: true)
                Rectangle()
                    .fill(Color.tanLine)
                    .frame(height: 2)
                ArchiveBuildStep(number: "2", title: "整理", isHighlighted: isThinking)
                Rectangle()
                    .fill(Color.tanLine)
                    .frame(height: 2)
                ArchiveBuildStep(number: "3", title: "入库", isHighlighted: false)
            }
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
                    Text("慢慢说，AI 会追问、整理，再生成一张能入库的摊档名片。")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                }
                Spacer()
                Button {
                    speakLatestAIQuestion()
                } label: {
                    Label("读问题", systemImage: "speaker.wave.2.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                        .padding(.horizontal, 11)
                        .frame(height: 34)
                        .background(Color.mutedOrange.opacity(0.6))
                        .clipShape(Capsule())
                }
            }
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
                    .frame(maxWidth: 292, alignment: .leading)
                    .background(message.role == "摊户" ? Color.tanPrimary : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color.tanInk.opacity(0.05), radius: 8, x: 0, y: 5)
                    if message.role != "摊户" {
                        Button {
                            speechReader.speak(message.text, dialect: dialect)
                        } label: {
                            Image(systemName: "speaker.wave.2")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.tanPrimary)
                                .frame(width: 32, height: 32)
                                .background(.white)
                                .clipShape(Circle())
                        }
                        Spacer(minLength: 40)
                    }
                }
            }

            if isThinking {
                HStack {
                    ProgressView()
                    Text("千问正在整理口述档案...")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous))
            }
        }
    }

    private var draftCard: some View {
        Surface {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: TanRadius.medium, style: .continuous)
                        .fill(Color.tanPrimary.opacity(0.14))
                    Image(systemName: draft.category.icon)
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(Color.tanPrimary)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 5) {
                    Text("AI 生成档案")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color.tanPrimary)
                    Text(draft.name)
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(Color.tanInk)
                }
            }

            Text(draft.summary)
                .font(.system(size: 14))
                .foregroundStyle(Color.tanInk.opacity(0.68))
                .lineSpacing(4)

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
                if let editingArchive {
                    store.updateArchive(editingArchive, with: draft)
                    dismiss()
                } else {
                    store.saveDraft(draft)
                }
            } label: {
                Text(editingArchive == nil ? "确认入库" : "保存修改")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    private var composer: some View {
        HStack(spacing: 10) {
            Menu {
                ForEach(ArchiveDialect.allCases, id: \.self) { item in
                    Button {
                        dialect = item
                        simulateDialectRecording()
                    } label: {
                        Label(item.title, systemImage: dialect == item ? "checkmark.circle.fill" : "mic.fill")
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 19, weight: .bold))
                    Text(dialect.title)
                        .font(.system(size: 15, weight: .black))
                }
                .foregroundStyle(Color.tanPrimary)
                .frame(width: 96, height: 46)
                .background(Color.tanPrimary.opacity(0.12))
                .clipShape(Capsule())
            }

            ChineseFriendlyTextField(placeholder: "回答 AI 的问题，或说“修改为...”", text: $input)
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(Color.tanPaper)
                .clipShape(Capsule())
            Button {
                send()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.tanPrimary.opacity(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isThinking ? 0.4 : 1))
                    .clipShape(Circle())
                    .shadow(color: Color.tanPrimary.opacity(0.2), radius: 10, x: 0, y: 6)
            }
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isThinking)
        }
        .padding(12)
        .background(.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.tanLine)
                .frame(height: 1)
        }
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(BuilderMessage(role: "摊户", text: text))
        input = ""
        isThinking = true

        Task {
            await applyQwenAgentUpdate(from: "建档语言：\(dialect.title)。\(text)")
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
            appendAIMessage("我先用本地 Agent 更新了草稿。网络或密钥不可用时不会影响演示；下一步请补充常出现的位置、是否带徒、以及最怕失传的细节。")
        }
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
        draft.summary = "AI 已根据摊户口述整理：\(text)。后续会结合用户照片、评论点赞与高积分反馈继续修订。"
        draft.craftProcess = ["口述采集", "工序拆解", "用户反馈补档", "云端同步"]
    }

    private func simulateDialectRecording() {
        input = "\(dialect.sampleText)"
    }

    private func appendAIMessage(_ text: String) {
        messages.append(BuilderMessage(role: "AI Agent", text: text))
        speechReader.speak(text, dialect: dialect)
    }

    private func speakLatestAIQuestion() {
        guard let text = messages.last(where: { $0.role == "AI Agent" })?.text else {
            return
        }
        speechReader.speak(text, dialect: dialect)
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

private enum ArchiveDialect: String, CaseIterable {
    case mandarin
    case chengdu
    case zigong

    var title: String {
        switch self {
        case .mandarin:
            return "普通话"
        case .chengdu:
            return "成都话"
        case .zigong:
            return "自贡话"
        }
    }

    var sampleText: String {
        switch self {
        case .mandarin:
            return "我这个摊做了二十多年，主要靠手工修补和老顾客口口相传。"
        case .chengdu:
            return "我这个摊摊摆了二十多年，老街坊都晓得，修鞋换拉链这些手艺还在坚持。"
        case .zigong:
            return "我这个摊摆了二十多年，修鞋换拉链这些活路都做得来，老街坊经常来找我。"
        }
    }
}

private final class SpeechReader: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String, dialect: ArchiveDialect) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = dialect == .mandarin ? 0.48 : 0.43
        utterance.pitchMultiplier = dialect == .chengdu ? 0.92 : 1.0
        synthesizer.speak(utterance)
    }
}
