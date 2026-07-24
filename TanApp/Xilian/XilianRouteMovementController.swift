import CoreLocation
import Foundation
import QuartzCore

enum XilianGuideState: Equatable {
    case idle
    case loadingRoute
    case ready
    case guiding
    case arrived
    case failed(String)
}

@MainActor
final class XilianRouteMovementController: ObservableObject {
    @Published private(set) var routeAnnotation: XilianRouteAnnotation?
    @Published private(set) var visualRevision = 0
    @Published private(set) var currentCoordinate: CLLocationCoordinate2D?
    @Published private(set) var isMoving = false
    @Published private(set) var progress: Double = 0
    @Published private(set) var hasArrived = false
    @Published private(set) var currentMessage: String?
    @Published private(set) var currentAnimationState: XilianAnimationState = .idle
    @Published private(set) var guideState: XilianGuideState = .idle

    private var movementTask: Task<Void, Never>?
    private var movementGeneration = 0
    private let animationDurationOverride: ((CLLocationDistance) -> TimeInterval)?

    init(animationDurationOverride: ((CLLocationDistance) -> TimeInterval)? = nil) {
        self.animationDurationOverride = animationDurationOverride
    }

    deinit {
        movementTask?.cancel()
    }

    func prepareRoute(
        at coordinate: CLLocationCoordinate2D,
        archiveID: UUID?,
        message: String
    ) {
        invalidateMovement()
        hasArrived = false
        progress = 0
        isMoving = false
        _ = ensureAnnotation(
            at: coordinate,
            archiveID: archiveID,
            message: message,
            state: .moving
        )
        guideState = .loadingRoute
    }

    func startMovingAlongRoute(
        coordinates: [CLLocationCoordinate2D],
        arrivalMessage: String,
        arrivalState: XilianAnimationState,
        archiveID: UUID?,
        onArrived: @escaping @MainActor () -> Void
    ) {
        invalidateMovement()
        let generation = movementGeneration
        hasArrived = false

        let path = XilianRoutePath(coordinates: coordinates)
        let startCoordinate = path.coordinate(atProgress: 0)
        let finalCoordinate = path.coordinate(atProgress: 1)

        guard path.coordinates.count > 1, path.totalDistance > 0 else {
            guard generation == movementGeneration else { return }
            placeAt(finalCoordinate, message: arrivalMessage, state: arrivalState, archiveID: archiveID)
            onArrived()
            return
        }

        let annotation = ensureAnnotation(
            at: startCoordinate,
            archiveID: archiveID,
            message: "昔涟正在前往摊位…",
            state: .moving
        )
        isMoving = true
        progress = 0
        guideState = .guiding

        let duration = max(
            animationDurationOverride?(path.totalDistance) ?? Self.animationDuration(for: path.totalDistance),
            0.01
        )
        movementTask = Task { @MainActor [weak self, weak annotation] in
            guard let self else { return }
            let startTime = CACurrentMediaTime()

            while !Task.isCancelled, self.movementGeneration == generation {
                let elapsed = CACurrentMediaTime() - startTime
                let newProgress = min(max(elapsed / duration, 0), 1)
                let coordinate = path.coordinate(atProgress: newProgress)

                annotation?.coordinate = coordinate
                self.currentCoordinate = coordinate
                self.progress = newProgress

                if newProgress >= 1 {
                    break
                }

                if Task.isCancelled { return }
                try? await Task.sleep(nanoseconds: 33_000_000)
                if Task.isCancelled { return }
            }

            guard !Task.isCancelled, self.movementGeneration == generation else { return }
            let finalCoordinate = path.coordinate(atProgress: 1)
            annotation?.coordinate = finalCoordinate
            annotation?.updateVisualState(
                animationState: arrivalState,
                message: arrivalMessage,
                archiveID: archiveID
            )
            self.currentCoordinate = finalCoordinate
            self.progress = 1
            self.currentMessage = arrivalMessage
            self.currentAnimationState = arrivalState
            self.isMoving = false
            self.hasArrived = true
            self.guideState = .arrived
            self.visualRevision += 1
            self.movementTask = nil
            onArrived()
        }
    }

    func placeAt(
        _ coordinate: CLLocationCoordinate2D,
        message: String,
        state: XilianAnimationState,
        archiveID: UUID? = nil
    ) {
        invalidateMovement()
        _ = ensureAnnotation(
            at: coordinate,
            archiveID: archiveID,
            message: message,
            state: state
        )
        routeAnnotation?.coordinate = coordinate
        currentCoordinate = coordinate
        currentMessage = message
        currentAnimationState = state
        isMoving = false
        progress = state == .moving ? 0 : 1
        hasArrived = state != .moving
        guideState = state == .moving ? .ready : .arrived
    }

    func stop() {
        invalidateMovement()
        isMoving = false
        guideState = .idle
    }

    func clear() {
        stop()
        routeAnnotation = nil
        currentCoordinate = nil
        currentMessage = nil
        currentAnimationState = .idle
        progress = 0
        hasArrived = false
        guideState = .idle
        visualRevision += 1
    }

    private static func animationDuration(for distance: CLLocationDistance) -> TimeInterval {
        let estimated = distance / 140.0
        return min(max(estimated, 8.0), 18.0)
    }

    private func invalidateMovement() {
        movementGeneration &+= 1
        movementTask?.cancel()
        movementTask = nil
    }

    private func ensureAnnotation(
        at coordinate: CLLocationCoordinate2D,
        archiveID: UUID?,
        message: String,
        state: XilianAnimationState
    ) -> XilianRouteAnnotation {
        let annotation: XilianRouteAnnotation
        if let routeAnnotation {
            annotation = routeAnnotation
            annotation.coordinate = coordinate
        } else {
            annotation = XilianRouteAnnotation(
                coordinate: coordinate,
                animationState: state,
                archiveID: archiveID,
                message: message
            )
            routeAnnotation = annotation
        }
        annotation.updateVisualState(
            animationState: state,
            message: message,
            archiveID: archiveID
        )
        currentCoordinate = coordinate
        currentMessage = message
        currentAnimationState = state
        visualRevision += 1
        return annotation
    }
}
