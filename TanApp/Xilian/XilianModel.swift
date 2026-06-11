import Foundation

struct XilianCompanion: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var mood: XilianMood

    init(id: UUID = UUID(), name: String = "昔涟", mood: XilianMood = .gentle) {
        self.id = id
        self.name = name
        self.mood = mood
    }

    static let defaultGreeting = "伙伴，我叫昔涟。那些藏在街巷里的旧记忆，就让我陪你一起找回来吧。"
}

enum XilianMood: String, Codable, CaseIterable {
    case gentle
    case curious
    case worried
    case happy
}

enum XilianQuickQuestion: String, CaseIterable, Identifiable {
    case nearby = "附近有什么摊？"
    case story = "这个摊有什么故事？"
    case needsHelp = "哪些摊需要补档？"
    case route = "我今天可以怎么逛？"

    var id: String { rawValue }
}

enum XilianCopy {
    static func statusHint(for archive: CityArchive) -> String {
        switch archive.status {
        case .open:
            return "伙伴，这个摊最近还挺活跃，我可以陪你去看看。"
        case .atRisk:
            return "伙伴，这个摊有段时间没人确认了。如果你路过，可以帮它留下一点线索。"
        case .closed:
            return "伙伴，这个摊暂时没有出摊记录，但过去的故事也值得被记住。"
        }
    }

    static func detailHint(for archive: CityArchive) -> String {
        switch archive.status {
        case .open:
            return "伙伴，这个摊最近还活跃，可以补一张最新照片。"
        case .atRisk:
            return "伙伴，这个摊有段时间没人确认了。如果你知道它还在，可以帮忙补档。"
        case .closed:
            return "伙伴，即使摊位暂时不在，过去的故事也值得被记录。"
        }
    }

    static func reply(
        to question: XilianQuickQuestion,
        selectedArchive: CityArchive?,
        nearbyArchives: [CityArchive]
    ) -> String {
        switch question {
        case .nearby:
            guard !nearbyArchives.isEmpty else {
                return "伙伴，附近暂时没有找到摊位。换个街口看看，也许会有新的记忆等着我们。"
            }
            return "伙伴，附近有 \(nearbyArchives.count) 个摊位可以看看。我建议先从最近或最活跃的摊开始。"
        case .story:
            guard let selectedArchive else {
                return "伙伴，先在地图上点一个摊位吧。我会把它的故事慢慢讲给你听。"
            }
            return "伙伴，这是 \(selectedArchive.ownerName) 的 \(selectedArchive.name)。\(selectedArchive.summary)"
        case .needsHelp:
            let count = nearbyArchives.filter { $0.status == .atRisk }.count
            if count > 0 {
                return "伙伴，有 \(count) 个摊位需要大家帮忙确认。路过时，可以帮它留下一张照片或一句话。"
            }
            return "伙伴，附近的摊位状态还不错。不过你也可以补一张照片，让记忆更完整。"
        case .route:
            if let selectedArchive {
                return "伙伴，可以先去 \(selectedArchive.name)，再看看附近同类摊位。走过的路线，会像涟漪一样留下记忆。"
            }
            return "伙伴，可以从附近最活跃的摊位开始。边走边看，我们一起把街巷里的故事找回来。"
        }
    }
}
