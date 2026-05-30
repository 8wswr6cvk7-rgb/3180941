//
//  Message.swift
//  3180941
//
//  Created by student01 on 2026/3/29.
//

import Foundation

struct Message: Identifiable, Equatable, Codable {
    let id: UUID
    var role: Role
    var content: String
    var imageBase64: String?

    enum Role: String, Codable {
        case user
        case assistant
    }

    init(id: UUID = UUID(), role: Role, content: String, imageBase64: String? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.imageBase64 = imageBase64
    }
}
