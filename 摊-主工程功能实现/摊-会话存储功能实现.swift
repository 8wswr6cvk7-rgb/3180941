//
//  ConversationStore.swift
//  3180941
//
//  Created by student01 on 2026/3/29.
//

import Combine
import Foundation

@MainActor
final class ConversationStore: ObservableObject {
    @Published private(set) var conversations: [Conversation] = []

    private static let storageKey = "ConversationStore.conversations"

    init() {
        load()
    }

    func conversation(id: UUID) -> Conversation? {
        conversations.first { $0.id == id }
    }

    @discardableResult
    func createConversation() -> UUID {
        let conv = Conversation(title: "新对话", messages: [], createdAt: Date())
        conversations.insert(conv, at: 0)
        save()
        return conv.id
    }

    func appendMessage(to conversationId: UUID, _ message: Message) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        conversations[index].messages.append(message)
        save()
    }

    func setTitle(_ conversationId: UUID, _ title: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        conversations[index].title = title
        save()
    }

    func deleteConversation(id: UUID) {
        conversations.removeAll { $0.id == id }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([Conversation].self, from: data) else {
            return
        }
        conversations = decoded.sorted { $0.createdAt > $1.createdAt }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(conversations) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
