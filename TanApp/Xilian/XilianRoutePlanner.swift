import CoreLocation
import MapKit
import Combine

@MainActor
final class XilianRoutePlanner: ObservableObject {
    private var activeDirections: MKDirections?

    func calculateRoute(
        from userCoordinate: CLLocationCoordinate2D,
        to destinationCoordinate: CLLocationCoordinate2D
    ) async throws -> MKRoute {
        activeDirections?.cancel()

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .walking
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)
        activeDirections = directions
        defer {
            if activeDirections === directions {
                activeDirections = nil
            }
        }

        let response = try await directions.calculate()
        try Task.checkCancellation()
        guard let route = response.routes.first else {
            throw MKError(.directionsNotFound)
        }
        return route
    }

    func cancel() {
        activeDirections?.cancel()
        activeDirections = nil
    }
}
