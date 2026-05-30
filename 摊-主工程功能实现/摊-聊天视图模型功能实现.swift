//
//  ChatViewModel.swift
//  3180941
//
//  Created by student01 on 2026/3/29.
//

import Combine
import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    enum ServiceProvider: String, CaseIterable {
        case dashScope = "DashScope"
        case coze = "Coze"
    }

    let conversationId: UUID
    private let store: ConversationStore
    private let api: APIService
    private let cozeAPI: CozeAPIService

    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var serviceProvider: ServiceProvider = .dashScope

    init(
        conversationId: UUID,
        store: ConversationStore,
        api: APIService = APIService(),
        cozeAPI: CozeAPIService = CozeAPIService()
    ) {
        self.conversationId = conversationId
        self.store = store
        self.api = api
        self.cozeAPI = cozeAPI
    }

    func sendUserMessage(_ text: String, imageBase64: String? = nil) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || imageBase64 != nil else { return }

        let priorUserCount = store.conversation(id: conversationId)?.messages.filter { $0.role == .user }.count ?? 0

        errorMessage = nil
        if !trimmed.isEmpty {
            let userMsg = Message(role: .user, content: trimmed)
            store.appendMessage(to: conversationId, userMsg)
        }
        if let imageBase64, !imageBase64.isEmpty {
            store.appendMessage(to: conversationId, Message(role: .user, content: "", imageBase64: imageBase64))
        }

        if priorUserCount == 0 {
            let title = String(trimmed.prefix(10))
            store.setTitle(conversationId, title.isEmpty ? "图片对话" : title)
        }

        isLoading = true
        defer { isLoading = false }

        let msgs = store.conversation(id: conversationId)?.messages ?? []

        do {
            let reply: String
            switch serviceProvider {
            case .dashScope:
                if imageBase64 != nil {
                    throw APIServiceError.imageNotSupportedByDashScope
                }
                reply = try await api.completeChat(messages: msgs)
            case .coze:
                reply = try await cozeAPI.completeChat(messages: msgs)
            }
            store.appendMessage(to: conversationId, Message(role: .assistant, content: reply))
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
