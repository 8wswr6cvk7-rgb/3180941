import Foundation
import UIKit

protocol ArchiveVisionAnalyzing {
    func analyze(image: UIImage) async throws -> ArchiveVisionHints
}

struct ArchiveVisionHints: Equatable {
    var categoryHint: String?
    var visibleItems: [String]
    var craftClues: [String]
    var environmentClues: [String]
    var uncertainties: [String]

    var isEmpty: Bool {
        categoryHint == nil
            && visibleItems.isEmpty
            && craftClues.isEmpty
            && environmentClues.isEmpty
            && uncertainties.isEmpty
    }

    var displaySummary: String {
        let parts = [
            categoryHint.map { "可能类别：\($0)" },
            visibleItems.isEmpty ? nil : "可见物品：\(visibleItems.joined(separator: "、"))",
            craftClues.isEmpty ? nil : "工序线索：\(craftClues.joined(separator: "、"))",
            environmentClues.isEmpty ? nil : "环境线索：\(environmentClues.joined(separator: "、"))"
        ].compactMap { $0 }
        return parts.joined(separator: "；")
    }

    var agentContext: String {
        var lines = [
            "照片可见线索（仅供摊主核对，不得据此推断人物身份、精确地址、从业年限或实时营业状态）：",
            displaySummary
        ]
        if !uncertainties.isEmpty {
            lines.append("需要确认：\(uncertainties.joined(separator: "、"))")
        }
        return lines.filter { !$0.isEmpty }.joined(separator: "\n")
    }
}

enum ArchiveVisionAnalysisState: Equatable {
    case idle
    case analyzing
    case ready
    case failed

    var isAnalyzing: Bool {
        self == .analyzing
    }
}

enum ArchiveVisionError: Error, Equatable {
    case missingAPIKey
    case imageEncodingFailed
    case requestFailed
    case emptyResponse
    case invalidResponse
}

final class QwenArchiveVisionService: ArchiveVisionAnalyzing {
    private let endpoint: URL
    private let session: URLSession
    private let configurationProvider: () -> LocalDashScopeConfiguration

    init(
        endpoint: URL = URL(string: "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions")!,
        session: URLSession = .shared,
        configurationProvider: @escaping () -> LocalDashScopeConfiguration = LocalDashScopeConfiguration.load
    ) {
        self.endpoint = endpoint
        self.session = session
        self.configurationProvider = configurationProvider
    }

    func analyze(image: UIImage) async throws -> ArchiveVisionHints {
        let configuration = configurationProvider()
        guard let apiKey = configuration.apiKey, !apiKey.isEmpty else {
            throw ArchiveVisionError.missingAPIKey
        }

        let imageDataURL = try ArchiveVisionImageEncoder.dataURL(from: image)
        let body = QwenVisionRequest(
            model: configuration.visionModelName,
            messages: [
                QwenVisionMessage(
                    role: "system",
                    content: [
                        .text(Self.systemPrompt)
                    ]
                ),
                QwenVisionMessage(
                    role: "user",
                    content: [
                        .imageURL(imageDataURL),
                        .text("请读取这张摊位或手艺现场照片，只返回约定 JSON。")
                    ]
                )
            ],
            temperature: 0.1
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 25
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw ArchiveVisionError.requestFailed
        }

        guard let responseBody = try? JSONDecoder().decode(QwenVisionResponse.self, from: data),
              let content = responseBody.choices.first?.message.content,
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ArchiveVisionError.emptyResponse
        }
        return try QwenArchiveVisionResponseParser.parse(content)
    }

    private static let systemPrompt = """
    你是「摊」App 的档案照片线索助手。照片可能是摊位、食物、作品、工具或街巷环境。
    只描述画面中直接可见的信息，不识别人名，不推断摊主身份、精确地址、从业年限、传承关系或实时营业状态。
    无法确认的信息必须放入 uncertainties。
    只输出 JSON，不要输出 Markdown 或解释，字段固定为：
    {
      "categoryHint": "可能的摊位或手艺类别，无法判断时为空字符串",
      "visibleItems": ["最多5项画面中直接可见的物品或作品"],
      "craftClues": ["最多4项可见的工具、动作或工序线索"],
      "environmentClues": ["最多3项可见的环境线索"],
      "uncertainties": ["最多3项需要摊主确认的信息"]
    }
    """
}

enum ArchiveVisionImageEncoder {
    static func dataURL(
        from image: UIImage,
        maximumDimension: CGFloat = 1_280,
        compressionQuality: CGFloat = 0.78
    ) throws -> String {
        let data = try jpegData(
            from: image,
            maximumDimension: maximumDimension,
            compressionQuality: compressionQuality
        )
        return "data:image/jpeg;base64,\(data.base64EncodedString())"
    }

    static func jpegData(
        from image: UIImage,
        maximumDimension: CGFloat = 1_280,
        compressionQuality: CGFloat = 0.78
    ) throws -> Data {
        let sourceSize = image.size
        guard sourceSize.width > 0, sourceSize.height > 0 else {
            throw ArchiveVisionError.imageEncodingFailed
        }

        let longestSide = max(sourceSize.width, sourceSize.height)
        let scale = min(1, maximumDimension / longestSide)
        let targetSize = CGSize(
            width: max(1, floor(sourceSize.width * scale)),
            height: max(1, floor(sourceSize.height * scale))
        )
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let normalized = UIGraphicsImageRenderer(size: targetSize, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        guard let data = normalized.jpegData(compressionQuality: compressionQuality) else {
            throw ArchiveVisionError.imageEncodingFailed
        }
        return data
    }
}

enum QwenArchiveVisionResponseParser {
    static func parse(_ content: String) throws -> ArchiveVisionHints {
        let jsonData = try extractJSONObject(from: content)
        guard let payload = try? JSONDecoder().decode(ArchiveVisionPayload.self, from: jsonData) else {
            throw ArchiveVisionError.invalidResponse
        }

        let hints = ArchiveVisionHints(
            categoryHint: normalizedCategory(payload.categoryHint),
            visibleItems: normalizedList(payload.visibleItems, limit: 5),
            craftClues: normalizedList(payload.craftClues, limit: 4),
            environmentClues: normalizedList(payload.environmentClues, limit: 3),
            uncertainties: normalizedList(payload.uncertainties, limit: 3)
        )
        guard !hints.isEmpty else {
            throw ArchiveVisionError.emptyResponse
        }
        return hints
    }

    private static func extractJSONObject(from content: String) throws -> Data {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let start = trimmed.firstIndex(of: "{"),
              let end = trimmed.lastIndex(of: "}"),
              start <= end else {
            throw ArchiveVisionError.invalidResponse
        }
        let json = String(trimmed[start...end])
        guard let data = json.data(using: .utf8) else {
            throw ArchiveVisionError.invalidResponse
        }
        return data
    }

    private static func normalizedCategory(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return nil
        }
        return String(trimmed.prefix(24))
    }

    private static func normalizedList(_ values: [String]?, limit: Int) -> [String] {
        var seen = Set<String>()
        return (values ?? []).compactMap { value in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, seen.insert(trimmed).inserted else { return nil }
            return String(trimmed.prefix(40))
        }
        .prefix(limit)
        .map { $0 }
    }
}

private struct ArchiveVisionPayload: Decodable {
    var categoryHint: String?
    var visibleItems: [String]?
    var craftClues: [String]?
    var environmentClues: [String]?
    var uncertainties: [String]?
}

private struct QwenVisionRequest: Encodable {
    var model: String
    var messages: [QwenVisionMessage]
    var temperature: Double
}

private struct QwenVisionMessage: Encodable {
    var role: String
    var content: [QwenVisionContent]
}

private struct QwenVisionContent: Encodable {
    var type: String
    var text: String?
    var imageURL: ImageURL?

    struct ImageURL: Encodable {
        var url: String
    }

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageURL = "image_url"
    }

    static func text(_ text: String) -> QwenVisionContent {
        QwenVisionContent(type: "text", text: text, imageURL: nil)
    }

    static func imageURL(_ url: String) -> QwenVisionContent {
        QwenVisionContent(type: "image_url", text: nil, imageURL: ImageURL(url: url))
    }
}

private struct QwenVisionResponse: Decodable {
    var choices: [Choice]

    struct Choice: Decodable {
        var message: Message
    }

    struct Message: Decodable {
        var content: String
    }
}
