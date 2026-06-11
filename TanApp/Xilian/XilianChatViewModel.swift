import Foundation

enum XilianChatRole {
    case xilian
    case user
}

struct XilianChatMessage: Identifiable {
    let id = UUID()
    let role: XilianChatRole
    let text: String
}

@MainActor
final class XilianChatViewModel: ObservableObject {
    @Published var messages: [XilianChatMessage]
    @Published var inputText = ""
    @Published var isThinking = false
    @Published var selectedQuickQuestion: XilianQuickQuestion?
    @Published var animationState: XilianAnimationState = .idle

    let selectedArchive: CityArchive?
    let nearbyArchives: [CityArchive]

    private let currentPage: XilianCurrentPage
    private let agent: XilianChatAgent

    init(
        selectedArchive: CityArchive?,
        nearbyArchives: [CityArchive],
        currentPage: XilianCurrentPage,
        agent: XilianChatAgent = XilianChatAgent()
    ) {
        self.selectedArchive = selectedArchive
        self.nearbyArchives = nearbyArchives
        self.currentPage = currentPage
        self.agent = agent
        messages = [
            XilianChatMessage(role: .xilian, text: XilianCompanion.defaultGreeting)
        ]
        animationState = selectedArchive?.status == .atRisk ? .worried : .idle
    }

    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isThinking
    }

    func askQuickQuestion(_ question: XilianQuickQuestion) {
        guard !isThinking else { return }
        selectedQuickQuestion = question
        messages.append(XilianChatMessage(role: .user, text: question.rawValue))
        let reply = XilianCopy.reply(
            to: question,
            selectedArchive: selectedArchive,
            nearbyArchives: nearbyArchives
        )
        appendXilianReply(reply)
    }

    func send() {
        let question = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !isThinking else { return }

        inputText = ""
        selectedQuickQuestion = nil
        messages.append(XilianChatMessage(role: .user, text: question))
        isThinking = true
        animationState = .thinking

        Task {
            do {
                let reply = try await agent.reply(
                    to: question,
                    selectedArchive: selectedArchive,
                    nearbyArchives: nearbyArchives,
                    currentPage: currentPage
                )
                isThinking = false
                appendXilianReply(reply)
            } catch {
                isThinking = false
                appendXilianReply(fallbackReply)
            }
        }
    }

    private var fallbackReply: String {
        var text = "伙伴，刚才那阵记忆的涟漪有点乱。我先陪你看看当前摊位和附近档案吧。"
        if let selectedArchive {
            text += "这个摊是 \(selectedArchive.ownerName) 的 \(selectedArchive.name)。\(selectedArchive.summary)"
        }
        return text
    }

    private func appendXilianReply(_ text: String) {
        messages.append(XilianChatMessage(role: .xilian, text: text))
        animationState = .speaking
        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            guard animationState == .speaking else { return }
            animationState = selectedArchive?.status == .atRisk ? .worried : .idle
        }
    }
}
