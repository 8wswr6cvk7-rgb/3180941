//
//  RegisterStallView.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import SwiftUI

struct RegisterStallView: View {
    @EnvironmentObject private var appModel: TanAppModel
    @Environment(\.dismiss) private var dismiss

    @State private var hasSelectedPhoto = false
    @State private var isRecording = false
    @State private var hasVoiceStory = false
    @State private var isGenerating = false
    @State private var generatedCard: StallRegistrationDraft?
    @State private var showSuccessAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("三步把街头摊位留进城市档案")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.tanSecondary)

                SectionCard {
                    Text("步骤 1 · 拍照")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.tanSecondary)

                    Button {
                        hasSelectedPhoto = true
                    } label: {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundStyle(Color.tanPrimary.opacity(0.7))
                            .frame(height: 180)
                            .overlay {
                                VStack(spacing: 12) {
                                    Image(systemName: hasSelectedPhoto ? "photo.fill" : "camera.fill")
                                        .font(.system(size: 34))
                                        .foregroundStyle(Color.tanPrimary)
                                    Text(hasSelectedPhoto ? "已模拟选图，继续录制摊主故事" : "点击模拟选图")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(Color.tanSecondary)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }

                SectionCard {
                    Text("步骤 2 · 语音录制")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.tanSecondary)

                    Button {
                        startRecordingFlow()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: isRecording ? "waveform.circle.fill" : "mic.fill")
                                .font(.system(size: 28))
                            Text(isRecording ? "模拟录音中（3秒）..." : hasVoiceStory ? "已录制完成" : "点击模拟录音 3 秒")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(hasSelectedPhoto ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(hasSelectedPhoto ? Color.tanPrimary : Color.gray.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(!hasSelectedPhoto || isRecording || isGenerating)
                }

                SectionCard {
                    Text("步骤 3 · AI 建档")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.tanSecondary)

                    if isGenerating {
                        VStack(spacing: 14) {
                            ProgressView()
                                .tint(Color.tanPrimary)
                                .scaleEffect(1.2)
                            Text("AI 正在整理摊位故事与关键信息...")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    } else if let generatedCard {
                        GeneratedCardView(card: generatedCard)
                    } else {
                        Text("完成拍照和录音后，系统会自动生成 mock 名片。")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 100)
        }
        .background(Color.tanBackground.ignoresSafeArea())
        .navigationTitle("摊主建档")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if generatedCard != nil {
                Button {
                    if let generatedCard {
                        appModel.completeRegistration(from: generatedCard)
                    }
                    showSuccessAlert = true
                } label: {
                    Text("确认建档")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.tanPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.tanBackground)
            }
        }
        .alert("建档完成", isPresented: $showSuccessAlert) {
            Button("返回我的页面") {
                dismiss()
            }
        } message: {
            Text("摊位数字名片已生成并进入原型展示流程。")
        }
    }

    private func startRecordingFlow() {
        guard hasSelectedPhoto, !isRecording else {
            return
        }

        isRecording = true
        hasVoiceStory = false
        generatedCard = nil

        Task {
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run {
                isRecording = false
                hasVoiceStory = true
                isGenerating = true
            }

            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                isGenerating = false
                generatedCard = StallRegistrationDraft(
                    name: "阿玲蛋烘糕",
                    category: "小吃",
                    price: "¥7/个",
                    businessHours: "15:30 - 21:00"
                )
            }
        }
    }
}

private struct GeneratedCardView: View {
    let card: StallRegistrationDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mock 名片")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.tanPrimary)

            Text(card.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.tanSecondary)

            infoRow(title: "品类", value: card.category)
            infoRow(title: "价格", value: card.price)
            infoRow(title: "营业时间", value: card.businessHours)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tanPrimary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.tanSecondary)
        }
    }
}

struct RegisterStallView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RegisterStallView()
                .environmentObject(TanAppModel())
        }
    }
}
