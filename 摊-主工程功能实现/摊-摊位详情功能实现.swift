//
//  StallDetailView.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import SwiftUI

struct StallDetailView: View {
    @EnvironmentObject private var appModel: TanAppModel

    let stall: Stall

    @State private var isPlayingStory = false
    @State private var showHelpBuySheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 280)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundStyle(.gray.opacity(0.6))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(stall.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(Color.tanSecondary)

                            Text("已在街头陪伴 \(stall.yearsActive) 年")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.tanPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.tanPrimary.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        Spacer()
                    }

                    StatusBadge(status: stall.status)
                }

                SectionCard {
                    Text("摊主故事")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.tanSecondary)

                    HStack(alignment: .top, spacing: 14) {
                        Button {
                            isPlayingStory.toggle()
                        } label: {
                            Image(systemName: isPlayingStory ? "pause.fill" : "play.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.tanPrimary)
                                .clipShape(Circle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(isPlayingStory ? "正在播放摊主口述..." : "点击收听摊主口述")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.tanSecondary)
                            Text(stall.description)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                SectionCard {
                    Text("用户照片墙")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.tanSecondary)

                    HStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(maxWidth: .infinity)
                                .frame(height: 92)
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundStyle(.gray.opacity(0.6))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }

                SectionCard {
                    Text("摊位档案")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.tanSecondary)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("\(stall.category) · \(stall.price)", systemImage: "tag.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                        Text(stall.description)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.tanSecondary)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 80)
        }
        .background(Color.tanBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    showHelpBuySheet = true
                } label: {
                    Text("帮我带一份")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.tanPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    appModel.toggleFavorite(stall)
                } label: {
                    Text(appModel.isFavorite(stall) ? "已收藏" : "收藏")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.tanSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 10)
            .background(Color.tanBackground)
        }
        .sheet(isPresented: $showHelpBuySheet) {
            HelpBuyView(stall: stall)
                .environmentObject(appModel)
                .presentationDetents([.medium, .large])
        }
    }
}

struct StallDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StallDetailView(stall: MockData.zhangDaYe)
                .environmentObject(TanAppModel())
        }
    }
}
