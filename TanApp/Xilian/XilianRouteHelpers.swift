import CoreLocation
import MapKit

enum XilianRouteHelpers {
    static func coordinates(from polyline: MKPolyline) -> [CLLocationCoordinate2D] {
        guard polyline.pointCount > 0 else { return [] }
        var coordinates = Array(
            repeating: kCLLocationCoordinate2DInvalid,
            count: polyline.pointCount
        )
        polyline.getCoordinates(&coordinates, range: NSRange(location: 0, length: polyline.pointCount))
        return coordinates
    }

    static func fallbackLine(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        steps: Int = 48
    ) -> [CLLocationCoordinate2D] {
        [start] + XilianCoordinateInterpolator.interpolateCoordinates(from: start, to: end, steps: steps)
    }
}
