//
//  HelpBuyView.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import SwiftUI

struct HelpBuyView: View {
    @EnvironmentObject private var appModel: TanAppModel
    @Environment(\.dismiss) private var dismiss

    let stall: Stall

    @State private var item = ""
    @State private var note = ""
    @State private var didSubmit = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionCard {
                        Text(stall.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.tanSecondary)
                        Text("告诉市井侠你想带什么，我们会先用 mock 数据完成这次委托。")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                    if didSubmit {
                        SectionCard {
                            Text("已发布，等待市井侠接单")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.tanPrimary)
                            Text("你的代购需求已经生成在「我的代购订单」里。")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        SectionCard {
                            Text("想要什么")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.tanSecondary)

                            TextField("例如：糖油果子两份", text: $item)
                                .textFieldStyle(.roundedBorder)

                            Text("备注")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.tanSecondary)

                            TextEditor(text: $note)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color.tanBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.tanBackground.ignoresSafeArea())
            .navigationTitle("帮我带一份")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !didSubmit {
                    Button {
                        didSubmit = true
                        appModel.submitOrder(for: stall, item: item, requesterName: appModel.currentUser.name)
                    } label: {
                        Text("提交")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.tanPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .disabled(item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.tanBackground)
                }
            }
        }
    }
}

struct HelpBuyView_Previews: PreviewProvider {
    static var previews: some View {
        HelpBuyView(stall: MockData.zhangDaYe)
            .environmentObject(TanAppModel())
    }
}
