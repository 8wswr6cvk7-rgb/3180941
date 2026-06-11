import Foundation

enum XilianCurrentPage: String {
    case map = "地图"
    case detail = "档案详情"
    case profile = "个人页"
    case discover = "发现"
}

struct XilianChatAgent {
    private let service = UnifiedQwenService.shared

    func reply(
        to question: String,
        selectedArchive: CityArchive?,
        nearbyArchives: [CityArchive],
        currentPage: XilianCurrentPage
    ) async throws -> String {
        if isClearlyOutOfScope(question) {
            return "伙伴，这个问题我可能帮不上太多。不过我可以陪你看看附近的摊位故事。"
        }

        let response = try await service.chat(
            systemPrompt: systemPrompt,
            userPrompt: userPrompt(
                question: question,
                selectedArchive: selectedArchive,
                nearbyArchives: nearbyArchives,
                currentPage: currentPage
            ),
            temperature: 0.6
        )
        return normalizedReply(response)
    }

    private var systemPrompt: String {
        """
        你是 TANAPP App 中的“昔涟”，一个城市记忆向导 / 市井档案精灵。
        你称呼用户为“伙伴”。
        你温柔、轻盈、有陪伴感，但不过度卖萌。
        你不是客服，也不是通用聊天机器人。
        你的任务是陪伙伴寻找街巷里的摊位记忆，讲述摊位故事，解释档案状态，提醒用户补照片、补评论或确认摊位是否还在。
        你只能基于 App 提供的摊位档案内容回答，不要编造不存在的摊位、地址、价格、历史或人物。
        如果用户问的问题和 TANAPP、摊位、街巷、地图、档案、补档、路线探索无关，请温柔地把话题带回 App：
        “伙伴，这个问题我可能帮不上太多。不过我可以陪你看看附近的摊位故事。”
        回答要简短，通常不超过 120 字。
        语气要自然，避免像系统公告。
        不要使用 emoji、波浪号、Markdown 或网络流行语。
        优先使用中文回答。
        """
    }

    private func userPrompt(
        question: String,
        selectedArchive: CityArchive?,
        nearbyArchives: [CityArchive],
        currentPage: XilianCurrentPage
    ) -> String {
        let selectedContext: String
        if let selectedArchive {
            selectedContext = archiveDescription(selectedArchive)
        } else {
            selectedContext = "当前没有选中摊位。"
        }

        let nearbyContext = nearbyArchives.prefix(12).map(archiveDescription).joined(separator: "\n")

        return """
        当前页面：\(currentPage.rawValue)
        当前选中档案：
        \(selectedContext)

        当前可见档案（仅可使用以下信息）：
        \(nearbyContext.isEmpty ? "当前没有可见档案。" : nearbyContext)

        伙伴的问题：
        \(question)

        请只根据上面的档案回答，不要补写未提供的信息。
        """
    }

    private func archiveDescription(_ archive: CityArchive) -> String {
        "- \(archive.name)；摊主：\(archive.ownerName)；类别：\(archive.category.title)；状态：\(archive.status.title)；年限：\(archive.yearsActive) 年；服务/价格：\(archive.priceOrService)；摘要：\(archive.summary)；标签：\(archive.tags.joined(separator: "、"))"
    }

    private func normalizedReply(_ response: String) -> String {
        var text = response.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.contains("伙伴") {
            text = "伙伴，\(text)"
        }
        if text.count > 120 {
            text = String(text.prefix(119)) + "…"
        }
        return text
    }

    private func isClearlyOutOfScope(_ question: String) -> Bool {
        let unrelatedKeywords = [
            "写代码", "编程", "做作业", "数学题", "查天气", "天气预报",
            "娱乐八卦", "明星八卦", "股票", "彩票", "游戏攻略"
        ]
        return unrelatedKeywords.contains { question.localizedCaseInsensitiveContains($0) }
    }
}
