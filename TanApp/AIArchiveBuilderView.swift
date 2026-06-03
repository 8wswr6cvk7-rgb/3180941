//
//  AIArchiveBuilderView.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI

struct AIArchiveBuilderView: View {
    @EnvironmentObject private var store: ArchiveStore
    @State private var messages: [BuilderMessage] = [
        BuilderMessage(role: "AI Agent", text: "先告诉我：这个摊或手艺叫什么？做了多少年？最值得记录的工序是哪一步？")
    ]
    @State private var input = ""
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
    }

    private var ownerBanner: some View {
        Surface {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.tanPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text("摊户 AI Agent")
                        .font(.system(size: 22, weight: .bold))
                    Text("多轮提问、自动改写、吸收用户反馈补全档案")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var conversation: some View {
        VStack(spacing: 10) {
            ForEach(messages) { message in
                HStack {
                    if message.role == "摊户" {
                        Spacer(minLength: 40)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.role)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        Text(message.text)
                            .font(.system(size: 14))
                    }
                    .padding(12)
                    .background(message.role == "摊户" ? Color.tanPrimary.opacity(0.12) : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    if message.role != "摊户" {
                        Spacer(minLength: 40)
                    }
                }
            }
        }
    }

    private var draftCard: some View {
        Surface {
            Text("自动生成名片")
                .font(.system(size: 18, weight: .bold))
            Text(draft.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.tanPrimary)
            Text("\(draft.ownerName) · \(draft.category.title) · \(draft.yearsActive) 年")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            FlowTags(tags: draft.tags)
            Text(draft.summary)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .lineSpacing(4)

            Button {
                store.saveDraft(draft)
            } label: {
                Text("确认入库")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("回答 AI 的问题，或说“修改为...”", text: $input)
                .textFieldStyle(.roundedBorder)
            Button {
                send()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.tanPrimary)
            }
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(12)
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(BuilderMessage(role: "摊户", text: text))
        applyAgentUpdate(from: text)
        input = ""
    }

    private func applyAgentUpdate(from text: String) {
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

        messages.append(BuilderMessage(role: "AI Agent", text: "我已更新档案草稿。还需要补充：常出现的位置、是否带徒、以及最怕失传的细节。"))
    }
}

private struct BuilderMessage: Identifiable {
    let id = UUID()
    let role: String
    let text: String
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
