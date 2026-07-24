import CoreLocation
import Foundation

struct XilianRoutePath {
    let coordinates: [CLLocationCoordinate2D]
    let cumulativeDistances: [CLLocationDistance]
    let totalDistance: CLLocationDistance

    init(coordinates: [CLLocationCoordinate2D]) {
        let validCoordinates = coordinates.filter { CLLocationCoordinate2DIsValid($0) }
        self.coordinates = validCoordinates

        guard !validCoordinates.isEmpty else {
            cumulativeDistances = []
            totalDistance = 0
            return
        }

        var distances: [CLLocationDistance] = [0]
        var runningDistance: CLLocationDistance = 0

        for index in 1..<validCoordinates.count {
            let previous = CLLocation(
                latitude: validCoordinates[index - 1].latitude,
                longitude: validCoordinates[index - 1].longitude
            )
            let current = CLLocation(
                latitude: validCoordinates[index].latitude,
                longitude: validCoordinates[index].longitude
            )
            runningDistance += current.distance(from: previous)
            distances.append(runningDistance)
        }

        cumulativeDistances = distances
        totalDistance = runningDistance
    }

    func coordinate(atProgress progress: Double) -> CLLocationCoordinate2D {
        let clampedProgress = min(max(progress, 0), 1)
        return coordinate(atDistance: totalDistance * clampedProgress)
    }

    func coordinate(atDistance distance: CLLocationDistance) -> CLLocationCoordinate2D {
        guard let first = coordinates.first else {
            return kCLLocationCoordinate2DInvalid
        }
        guard coordinates.count > 1, totalDistance > 0 else {
            return first
        }

        let clampedDistance = min(max(distance, 0), totalDistance)
        if clampedDistance <= 0 {
            return first
        }
        if clampedDistance >= totalDistance, let last = coordinates.last {
            return last
        }

        guard let upperIndex = cumulativeDistances.firstIndex(where: { $0 >= clampedDistance }),
              upperIndex > 0 else {
            return first
        }

        let lowerIndex = upperIndex - 1
        let lowerDistance = cumulativeDistances[lowerIndex]
        let upperDistance = cumulativeDistances[upperIndex]
        let segmentDistance = upperDistance - lowerDistance

        guard segmentDistance > 0 else {
            return coordinates[upperIndex]
        }

        let segmentProgress = (clampedDistance - lowerDistance) / segmentDistance
        return Self.interpolatedCoordinate(
            from: coordinates[lowerIndex],
            to: coordinates[upperIndex],
            progress: segmentProgress
        )
    }

    static func interpolatedCoordinate(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        progress: Double
    ) -> CLLocationCoordinate2D {
        let clampedProgress = min(max(progress, 0), 1)
        var longitudeDelta = end.longitude - start.longitude
        if longitudeDelta > 180 {
            longitudeDelta -= 360
        } else if longitudeDelta < -180 {
            longitudeDelta += 360
        }
        var longitude = start.longitude + longitudeDelta * clampedProgress
        if longitude > 180 {
            longitude -= 360
        } else if longitude < -180 {
            longitude += 360
        }
        return CLLocationCoordinate2D(
            latitude: start.latitude + (end.latitude - start.latitude) * clampedProgress,
            longitude: longitude
        )
    }
}
