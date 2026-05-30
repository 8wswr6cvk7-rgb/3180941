//
//  Models.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import Foundation
import CoreLocation

enum StallStatus: String, Codable, CaseIterable {
    case open
    case closed
    case gone

    var title: String {
        switch self {
        case .open:
            return "营业中"
        case .closed:
            return "已收摊"
        case .gone:
            return "消失预警"
        }
    }
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending
    case accepted
    case completed

    var title: String {
        switch self {
        case .pending:
            return "待接单"
        case .accepted:
            return "已接单"
        case .completed:
            return "已完成"
        }
    }
}

enum OrderBucket: String, Codable, CaseIterable {
    case published
    case received

    var title: String {
        switch self {
        case .published:
            return "发布订单"
        case .received:
            return "接收订单"
        }
    }
}

struct Stall: Identifiable, Hashable {
    let id: UUID
    let name: String
    let ownerName: String
    let category: String
    let price: String
    let location: CLLocationCoordinate2D
    let status: StallStatus
    let yearsActive: Int
    let photoURL: String
    let voiceStoryURL: String
    let description: String

    static func == (lhs: Stall, rhs: Stall) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Order: Identifiable, Hashable {
    let id: UUID
    let stallId: UUID
    let requesterName: String
    let item: String
    let status: OrderStatus
    let bucket: OrderBucket
}

struct User: Identifiable, Hashable {
    let id: UUID
    let name: String
    let points: Int
}

struct StallRegistrationDraft: Hashable {
    let name: String
    let category: String
    let price: String
    let businessHours: String
}
