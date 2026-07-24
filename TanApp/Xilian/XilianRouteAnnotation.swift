import MapKit

final class XilianRouteAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var animationState: XilianAnimationState
    var archiveID: UUID?
    var message: String
    var title: String? { "昔涟" }

    init(
        coordinate: CLLocationCoordinate2D,
        animationState: XilianAnimationState = .idle,
        archiveID: UUID? = nil,
        message: String = ""
    ) {
        self.coordinate = coordinate
        self.animationState = animationState
        self.archiveID = archiveID
        self.message = message
        super.init()
    }

    func updateVisualState(
        animationState: XilianAnimationState,
        message: String,
        archiveID: UUID?
    ) {
        self.animationState = animationState
        self.message = message
        self.archiveID = archiveID
    }
}
