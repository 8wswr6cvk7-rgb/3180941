//
//  OrdersView.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import SwiftUI

struct OrdersView: View {
    @EnvironmentObject private var appModel: TanAppModel
    @State private var selectedBucket: OrderBucket = .published

    private var displayedOrders: [Order] {
        switch selectedBucket {
        case .published:
            return appModel.publishedOrders
        case .received:
            return appModel.receivedOrders
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("订单分类", selection: $selectedBucket) {
                    ForEach(OrderBucket.allCases, id: \.self) { bucket in
                        Text(bucket.title).tag(bucket)
                    }
                }
                .pickerStyle(.segmented)

                if displayedOrders.isEmpty {
                    SectionCard {
                        Text(selectedBucket == .published ? "还没有发布订单。" : "还没有接收到帮带订单。")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(displayedOrders) { order in
                        SectionCard {
                            Text(appModel.stall(for: order)?.name ?? "摊位待确认")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.tanSecondary)

                            Text(order.item)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.tanSecondary)

                            HStack {
                                Text(selectedBucket == .published ? "委托人：\(order.requesterName)" : "求带人：\(order.requesterName)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(order.status.title)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.tanPrimary)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.tanBackground.ignoresSafeArea())
        .navigationTitle("我的代购订单")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OrdersView()
                .environmentObject(TanAppModel())
        }
    }
}
