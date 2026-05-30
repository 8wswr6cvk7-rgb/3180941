//
//  DisappearWarningView.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import SwiftUI

struct DisappearWarningView: View {
    @Environment(\.dismiss) private var dismiss

    let stall: Stall
    let inactiveDays: Int
    let onStillHere: () -> Void
    let onConfirmGone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 42, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

            Text("消失预警")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.tanSecondary)

            Text("\(stall.ownerName)的摊已\(inactiveDays)天未营业")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.tanSecondary)

            Text("如果你最近还见过这位摊主，可以帮忙更新状态；也可以确认这条街头档案进入消失记录。")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                Button {
                    onStillHere()
                    dismiss()
                } label: {
                    Text("我看到他还在")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.tanPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    onConfirmGone()
                    dismiss()
                } label: {
                    Text("确认已消失")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.tanSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .background(Color.tanBackground.ignoresSafeArea())
    }
}

struct DisappearWarningView_Previews: PreviewProvider {
    static var previews: some View {
        DisappearWarningView(
            stall: MockData.liYeYe,
            inactiveDays: 32,
            onStillHere: { },
            onConfirmGone: { }
        )
    }
}
