//
//  Conversation.swift
//  3180941
//
//  Created by student01 on 2026/3/29.
//

import Foundation

struct Conversation: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var messages: [Message]
    let createdAt: Date

    init(id: UUID = UUID(), title: String, messages: [Message] = [], createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
    }
}
