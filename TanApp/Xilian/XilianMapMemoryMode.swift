import Foundation

enum XilianMapMemoryMode: String, CaseIterable, Identifiable {
    case auto
    case visited
    case lit
    case needsArchive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .auto:
            return "自动"
        case .visited:
            return "走过"
        case .lit:
            return "点亮"
        case .needsArchive:
            return "补档"
        }
    }

    var menuTitle: String {
        "昔涟去哪？\(title)"
    }

    var fallbackMessage: String? {
        switch self {
        case .auto:
            return nil
        case .visited:
            return "伙伴，我们还没有走过任何摊位。先点一个看看吧。"
        case .lit:
            return "伙伴，还没有被你点亮的记忆。可以先点赞、评论或补一张照片。"
        case .needsArchive:
            return "伙伴，附近暂时没有需要补档的摊位。"
        }
    }
}
