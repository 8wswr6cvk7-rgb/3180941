//
//  StallLocationManager.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import Foundation
import CoreLocation

final class StallLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentCoordinate: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus

    private let manager = CLLocationManager()
    override init() {
        authorizationStatus = manager.authorizationStatus
        currentCoordinate = nil
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 8
    }

    func requestAndStartUpdating() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentCoordinate = locations.last?.coordinate
    }
}

enum XilianGuideOriginSource: Equatable {
    case liveLocation
    case chengduReferenceLocation
}

struct XilianGuideOriginDecision {
    let coordinate: CLLocationCoordinate2D
    let source: XilianGuideOriginSource
}

enum XilianGuideOriginPolicy {
    static let chengduReferenceCoordinate = CLLocationCoordinate2D(latitude: 30.6570, longitude: 104.0658)
    static let chengduRange: CLLocationDistance = 50_000

    static func decision(for coordinate: CLLocationCoordinate2D?) -> XilianGuideOriginDecision {
        guard let coordinate, CLLocationCoordinate2DIsValid(coordinate) else {
            return XilianGuideOriginDecision(
                coordinate: chengduReferenceCoordinate,
                source: .chengduReferenceLocation
            )
        }

        let current = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let chengdu = CLLocation(
            latitude: chengduReferenceCoordinate.latitude,
            longitude: chengduReferenceCoordinate.longitude
        )
        guard current.distance(from: chengdu) <= chengduRange else {
            return XilianGuideOriginDecision(
                coordinate: chengduReferenceCoordinate,
                source: .chengduReferenceLocation
            )
        }
        return XilianGuideOriginDecision(coordinate: coordinate, source: .liveLocation)
    }
}
