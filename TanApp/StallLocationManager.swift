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
    private static let tianfuSquare = CLLocationCoordinate2D(latitude: 30.6570, longitude: 104.0658)

    override init() {
        authorizationStatus = manager.authorizationStatus
#if targetEnvironment(simulator)
        currentCoordinate = Self.tianfuSquare
#else
        currentCoordinate = nil
#endif
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 8
    }

    func requestAndStartUpdating() {
#if targetEnvironment(simulator)
        currentCoordinate = Self.tianfuSquare
#else
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
#endif
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
#if targetEnvironment(simulator)
        currentCoordinate = Self.tianfuSquare
#else
        currentCoordinate = locations.last?.coordinate
#endif
    }
}

enum XilianGuideOriginSource: Equatable {
    case liveLocation
    case chengduDemoLocation
}

struct XilianGuideOriginDecision {
    let coordinate: CLLocationCoordinate2D
    let source: XilianGuideOriginSource
}

enum XilianGuideOriginPolicy {
    static let chengduDemoCoordinate = CLLocationCoordinate2D(latitude: 30.6570, longitude: 104.0658)
    static let chengduRange: CLLocationDistance = 50_000

    static func decision(for coordinate: CLLocationCoordinate2D?) -> XilianGuideOriginDecision {
        guard let coordinate, CLLocationCoordinate2DIsValid(coordinate) else {
            return XilianGuideOriginDecision(
                coordinate: chengduDemoCoordinate,
                source: .chengduDemoLocation
            )
        }

        let current = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let chengdu = CLLocation(
            latitude: chengduDemoCoordinate.latitude,
            longitude: chengduDemoCoordinate.longitude
        )
        guard current.distance(from: chengdu) <= chengduRange else {
            return XilianGuideOriginDecision(
                coordinate: chengduDemoCoordinate,
                source: .chengduDemoLocation
            )
        }
        return XilianGuideOriginDecision(coordinate: coordinate, source: .liveLocation)
    }
}
