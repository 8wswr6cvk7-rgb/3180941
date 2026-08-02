import CoreLocation
import Foundation

enum XilianMemoryTargetType: String, Hashable {
    case visited
    case lit
    case needsArchive

    var animationState: XilianAnimationState {
        switch self {
        case .visited:
            return .idle
        case .lit:
            return .happy
        case .needsArchive:
            return .worried
        }
    }
}

struct XilianMemoryTarget: Identifiable, Hashable {
    let id: UUID
    let archive: CityArchive
    let type: XilianMemoryTargetType
    let message: String

    init(archive: CityArchive, type: XilianMemoryTargetType, message: String? = nil) {
        self.id = archive.id
        self.archive = archive
        self.type = type
        self.message = message ?? Self.defaultMessage(for: archive, type: type)
    }

    var coordinate: CLLocationCoordinate2D {
        Self.offsetCoordinate(archive.currentLocation.coordinate)
    }

    static func offsetCoordinate(
        _ coordinate: CLLocationCoordinate2D,
        latitudeOffset: Double = 0.00006,
        longitudeOffset: Double = 0.00006
    ) -> CLLocationCoordinate2D {
        XilianCoordinateInterpolator.offsetCoordinate(
            coordinate,
            latitudeOffset: latitudeOffset,
            longitudeOffset: longitudeOffset
        )
    }

    private static func defaultMessage(for archive: CityArchive, type: XilianMemoryTargetType) -> String {
        switch type {
        case .visited:
            return "伙伴，这里是你刚刚走过的 \(archive.name)，这段记忆已经留下了涟漪。"
        case .lit:
            return "伙伴，\(archive.name) 被你点亮过，记忆又清晰了一点。"
        case .needsArchive:
            if archive.presentationStatus == .atRisk {
                return "伙伴，\(archive.name) 有段时间没人确认了。如果你路过，可以帮它留下一点线索。"
            }
            return "伙伴，\(archive.name) 这里有一段需要补档的记忆。"
        }
    }
}

struct XilianMapAnnotationState: Identifiable, Hashable {
    let id: String
    let coordinate: CoordinatePoint
    let target: XilianMemoryTarget?
    let message: String
    let animationState: XilianAnimationState

    init(target: XilianMemoryTarget) {
        id = "\(target.id.uuidString)-\(target.type.rawValue)"
        coordinate = CoordinatePoint(target.coordinate)
        self.target = target
        message = target.message
        animationState = target.type.animationState
    }

    init(userCoordinate: CLLocationCoordinate2D) {
        id = "user-location"
        coordinate = CoordinatePoint(
            XilianMemoryTarget.offsetCoordinate(
                userCoordinate,
                latitudeOffset: 0.00008,
                longitudeOffset: 0.00008
            )
        )
        target = nil
        message = "伙伴，我在这里陪你看这片街巷。"
        animationState = .idle
    }

    init(
        id: String,
        coordinate: CLLocationCoordinate2D,
        target: XilianMemoryTarget?,
        message: String,
        animationState: XilianAnimationState
    ) {
        self.id = id
        self.coordinate = CoordinatePoint(coordinate)
        self.target = target
        self.message = message
        self.animationState = animationState
    }
}
