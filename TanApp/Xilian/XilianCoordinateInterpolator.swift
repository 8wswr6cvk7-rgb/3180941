import CoreLocation
import Foundation

enum XilianCoordinateInterpolator {
    static func offsetCoordinate(
        _ coordinate: CLLocationCoordinate2D,
        latitudeOffset: Double = 0.00006,
        longitudeOffset: Double = 0.00006
    ) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: coordinate.latitude + latitudeOffset,
            longitude: coordinate.longitude + longitudeOffset
        )
    }

    static func interpolateCoordinates(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        steps: Int = 30
    ) -> [CLLocationCoordinate2D] {
        let safeSteps = max(1, steps)
        return (1...safeSteps).map { step in
            let progress = Double(step) / Double(safeSteps)
            return CLLocationCoordinate2D(
                latitude: start.latitude + (end.latitude - start.latitude) * progress,
                longitude: start.longitude + (end.longitude - start.longitude) * progress
            )
        }
    }

    static func coordinatesNearlyEqual(
        _ lhs: CLLocationCoordinate2D?,
        _ rhs: CLLocationCoordinate2D,
        tolerance: Double = 0.000005
    ) -> Bool {
        guard let lhs else { return false }
        return abs(lhs.latitude - rhs.latitude) < tolerance
            && abs(lhs.longitude - rhs.longitude) < tolerance
    }

    static func coordinateKey(_ coordinates: [CLLocationCoordinate2D]) -> String {
        coordinates
            .map { String(format: "%.6f,%.6f", $0.latitude, $0.longitude) }
            .joined(separator: "|")
    }
}
