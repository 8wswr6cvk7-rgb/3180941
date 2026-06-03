//
//  QwenArchiveAgent.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import Foundation

struct QwenArchiveAgent {
    private let endpoint = URL(string: "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions")!

    func refineDraft(
        currentDraft: AIArchiveDraft,
        userText: String,
        userName: String
    ) async throws -> QwenArchiveAgentResult {
        guard let apiKey = LocalQwenSecrets.load().apiKey, !apiKey.isEmpty else {
            throw QwenArchiveAgentError.missingAPIKey
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 20

        let body = QwenChatRequest(
            model: LocalQwenSecrets.load().model,
            messages: [
                QwenChatMessage(role: "system", content: systemPrompt),
                QwenChatMessage(role: "user", content: userPrompt(currentDraft: currentDraft, userText: userText, userName: userName))
            ],
            temperature: 0.35
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw QwenArchiveAgentError.requestFailed
        }

        let chatResponse = try JSONDecoder().decode(QwenChatResponse.self, from: data)
        guard let content = chatResponse.choices.first?.message.content else {
            throw QwenArchiveAgentError.emptyResponse
        }

        let jsonData = try extractJSONObject(from: content)
        return try JSONDecoder().decode(QwenArchiveAgentResult.self, from: jsonData)
    }

    private var systemPrompt: String {
        """
        你是「摊」App 的市井档案 AI Agent，帮助摊户把口述内容整理为可入库档案。
        平台方向是：市井档案 + 老手艺 / 非遗 / 老行当 / 饮食手艺 / 文化体验。
        请只输出 JSON，不要输出 Markdown，不要解释。
        JSON 字段：
        name: String
        ownerName: String
        category: snack | produce | heritageCraft | oldTrade | cultureExperience | other
        tags: [String]，最多 3 个
        priceOrService: String
        yearsActive: Int
        summary: String，60 字以内，温暖市井感
        craftProcess: [String]，3 到 5 步
        nextQuestion: String，继续追问一个最重要的信息
        """
    }

    private func userPrompt(currentDraft: AIArchiveDraft, userText: String, userName: String) -> String {
        """
        当前摊户昵称：\(userName)
        当前草稿：
        名称：\(currentDraft.name)
        摊主：\(currentDraft.ownerName)
        品类：\(currentDraft.category.rawValue)
        标签：\(currentDraft.tags.joined(separator: "、"))
        服务/价格：\(currentDraft.priceOrService)
        年限：\(currentDraft.yearsActive)
        摘要：\(currentDraft.summary)
        工序：\(currentDraft.craftProcess.joined(separator: "、"))

        摊户新回复：
        \(userText)

        请根据新回复修订草稿；如果信息缺失，用合理占位但不要编造具体地址。
        """
    }

    private func extractJSONObject(from content: String) throws -> Data {
        if let data = content.data(using: .utf8),
           (try? JSONSerialization.jsonObject(with: data)) != nil {
            return data
        }

        guard
            let start = content.firstIndex(of: "{"),
            let end = content.lastIndex(of: "}")
        else {
            throw QwenArchiveAgentError.invalidJSON
        }

        let json = String(content[start...end])
        guard let data = json.data(using: .utf8) else {
            throw QwenArchiveAgentError.invalidJSON
        }
        return data
    }
}

struct QwenArchiveAgentResult: Decodable {
    var name: String
    var ownerName: String
    var category: ArchiveCategory
    var tags: [String]
    var priceOrService: String
    var yearsActive: Int
    var summary: String
    var craftProcess: [String]
    var nextQuestion: String

    var draft: AIArchiveDraft {
        AIArchiveDraft(
            name: name,
            ownerName: ownerName,
            category: category,
            tags: Array(tags.prefix(3)),
            priceOrService: priceOrService,
            yearsActive: max(1, yearsActive),
            summary: summary,
            craftProcess: craftProcess
        )
    }
}

enum QwenArchiveAgentError: Error {
    case missingAPIKey
    case requestFailed
    case emptyResponse
    case invalidJSON
}

private struct QwenChatRequest: Encodable {
    var model: String
    var messages: [QwenChatMessage]
    var temperature: Double
}

private struct QwenChatMessage: Codable {
    var role: String
    var content: String
}

private struct QwenChatResponse: Decodable {
    var choices: [Choice]

    struct Choice: Decodable {
        var message: QwenChatMessage
    }
}

private struct LocalQwenSecrets: Decodable {
    var dashscopeAPIKey: String?
    var qwenModel: String?

    var apiKey: String? {
        dashscopeAPIKey?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var model: String {
        let value = qwenModel?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "qwen-plus" : value
    }

    static func load() -> LocalQwenSecrets {
        guard
            let url = Bundle.main.url(forResource: "LocalSecrets", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let secrets = try? JSONDecoder().decode(LocalQwenSecrets.self, from: data)
        else {
            return LocalQwenSecrets(dashscopeAPIKey: nil, qwenModel: "qwen-plus")
        }
        return secrets
    }
}
