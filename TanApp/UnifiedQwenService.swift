import Foundation

final class UnifiedQwenService {
    static let shared = UnifiedQwenService()

    private let endpoint = URL(string: "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions")!
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func chat(
        systemPrompt: String,
        userPrompt: String,
        temperature: Double = 0.7
    ) async throws -> String {
        let configuration = LocalDashScopeConfiguration.load()
        guard let apiKey = configuration.apiKey, !apiKey.isEmpty else {
            throw UnifiedQwenServiceError.missingAPIKey
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 20
        request.httpBody = try JSONEncoder().encode(
            QwenChatRequest(
                model: configuration.qwenModelName,
                messages: [
                    QwenChatMessage(role: "system", content: systemPrompt),
                    QwenChatMessage(role: "user", content: userPrompt)
                ],
                temperature: temperature
            )
        )

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw UnifiedQwenServiceError.requestFailed
        }

        let chatResponse = try JSONDecoder().decode(QwenChatResponse.self, from: data)
        guard let content = chatResponse.choices.first?.message.content
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !content.isEmpty else {
            throw UnifiedQwenServiceError.emptyResponse
        }
        return content
    }
}

enum UnifiedQwenServiceError: Error {
    case missingAPIKey
    case requestFailed
    case emptyResponse
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

struct LocalDashScopeConfiguration: Decodable {
    var dashscopeAPIKey: String?
    var qwenModel: String?
    var qwenVisionModel: String?
    var funASRModel: String?

    var apiKey: String? {
        dashscopeAPIKey?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var qwenModelName: String {
        let value = qwenModel?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "qwen-plus" : value
    }

    var visionModelName: String {
        let value = qwenVisionModel?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "qwen-vl-plus" : value
    }

    var asrModel: String {
        let value = funASRModel?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "fun-asr-realtime" : value
    }

    static func load() -> LocalDashScopeConfiguration {
        guard
            let url = Bundle.main.url(forResource: "LocalSecrets", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let secrets = try? JSONDecoder().decode(LocalDashScopeConfiguration.self, from: data)
        else {
            return LocalDashScopeConfiguration(
                dashscopeAPIKey: nil,
                qwenModel: "qwen-plus",
                funASRModel: "fun-asr-realtime"
            )
        }
        return secrets
    }
}
