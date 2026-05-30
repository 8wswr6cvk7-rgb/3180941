//
//  TanAppModel.swift
//  3180941
//
//  Created by Codex on 2026/5/30.
//

import Foundation
import CoreLocation

final class TanAppModel: ObservableObject {
    @Published var stalls: [Stall] = MockData.stalls
    @Published var orders: [Order] = MockData.sampleOrders
    @Published var currentUser: User = MockData.currentUser
    @Published var favoriteStallIDs: Set<UUID> = MockData.initialFavoriteIDs
    @Published var registeredStallID: UUID?

    var favoriteStalls: [Stall] {
        stalls.filter { favoriteStallIDs.contains($0.id) }
    }

    var registeredStall: Stall? {
        guard let registeredStallID else {
            return nil
        }

        return stalls.first(where: { $0.id == registeredStallID })
    }

    var hasRegisteredStall: Bool {
        registeredStall != nil
    }

    var isRegisteredStallOpen: Bool {
        registeredStall?.status == .open
    }

    var publishedOrders: [Order] {
        orders.filter { $0.bucket == .published }
    }

    var receivedOrders: [Order] {
        orders.filter { $0.bucket == .received }
    }

    var rankingText: String {
        "成都第 12 名"
    }

    func isFavorite(_ stall: Stall) -> Bool {
        favoriteStallIDs.contains(stall.id)
    }

    func toggleFavorite(_ stall: Stall) {
        if favoriteStallIDs.contains(stall.id) {
            favoriteStallIDs.remove(stall.id)
        } else {
            favoriteStallIDs.insert(stall.id)
        }
    }

    func submitOrder(for stall: Stall, item: String, requesterName: String) {
        let newOrder = Order(
            id: UUID(),
            stallId: stall.id,
            requesterName: requesterName,
            item: item,
            status: .pending,
            bucket: .published
        )
        orders.insert(newOrder, at: 0)
    }

    func searchStalls(query: String, category: String = "全部") -> [Stall] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        return stalls.filter { stall in
            let matchesCategory = category == "全部" || stall.category == category

            guard !trimmedQuery.isEmpty else {
                return matchesCategory
            }

            let searchableText = [
                stall.name,
                stall.ownerName,
                stall.category,
                stall.price,
                stall.description,
                stall.status.title,
                "\(stall.yearsActive)"
            ].joined(separator: " ")

            return matchesCategory && searchableText.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    func completeRegistration(from draft: StallRegistrationDraft) {
        if let registeredStallID, let index = stalls.firstIndex(where: { $0.id == registeredStallID }) {
            let current = stalls[index]
            stalls[index] = Stall(
                id: current.id,
                name: draft.name,
                ownerName: currentUser.name,
                category: draft.category,
                price: draft.price,
                location: current.location,
                status: current.status,
                yearsActive: max(current.yearsActive, 1),
                photoURL: "",
                voiceStoryURL: "voice://registered-stall-story",
                description: "由 \(currentUser.name) 建档，营业时间 \(draft.businessHours)。"
            )
            return
        }

        let stall = Stall(
            id: UUID(),
            name: draft.name,
            ownerName: currentUser.name,
            category: draft.category,
            price: draft.price,
            location: MockData.chengduCenter,
            status: .closed,
            yearsActive: 1,
            photoURL: "",
            voiceStoryURL: "voice://registered-stall-story",
            description: "由 \(currentUser.name) 建档，营业时间 \(draft.businessHours)。"
        )

        stalls.insert(stall, at: 0)
        registeredStallID = stall.id
    }

    func openRegisteredStall(at coordinate: CLLocationCoordinate2D) {
        guard let registeredStallID else {
            return
        }

        update(stallID: registeredStallID) { current in
            Stall(
                id: current.id,
                name: current.name,
                ownerName: current.ownerName,
                category: current.category,
                price: current.price,
                location: coordinate,
                status: .open,
                yearsActive: current.yearsActive,
                photoURL: current.photoURL,
                voiceStoryURL: current.voiceStoryURL,
                description: current.description
            )
        }
    }

    func updateRegisteredStallLocation(_ coordinate: CLLocationCoordinate2D) {
        guard let registeredStallID else {
            return
        }

        update(stallID: registeredStallID) { current in
            Stall(
                id: current.id,
                name: current.name,
                ownerName: current.ownerName,
                category: current.category,
                price: current.price,
                location: coordinate,
                status: current.status,
                yearsActive: current.yearsActive,
                photoURL: current.photoURL,
                voiceStoryURL: current.voiceStoryURL,
                description: current.description
            )
        }
    }

    func closeRegisteredStall() {
        guard let registeredStallID else {
            return
        }

        update(stallID: registeredStallID) { current in
            Stall(
                id: current.id,
                name: current.name,
                ownerName: current.ownerName,
                category: current.category,
                price: current.price,
                location: current.location,
                status: .closed,
                yearsActive: current.yearsActive,
                photoURL: current.photoURL,
                voiceStoryURL: current.voiceStoryURL,
                description: current.description
            )
        }
    }

    func activeNearbyCount(center: CLLocationCoordinate2D = MockData.chengduCenter, radius: CLLocationDistance = 2500) -> Int {
        stalls.filter {
            $0.status == .open &&
            CLLocation(latitude: center.latitude, longitude: center.longitude)
                .distance(from: CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude)) <= radius
        }.count
    }

    func distanceText(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> String {
        let distance = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
            .distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))

        if distance >= 1000 {
            return String(format: "%.1fkm", distance / 1000)
        }

        return "\(Int(distance))m"
    }

    func stall(for order: Order) -> Stall? {
        stalls.first(where: { $0.id == order.stallId })
    }

    func inactiveDays(for stall: Stall) -> Int {
        MockData.inactiveDays[stall.id] ?? 0
    }

    func reportStillHere(for stall: Stall) {
        update(stallID: stall.id) { current in
            Stall(
                id: current.id,
                name: current.name,
                ownerName: current.ownerName,
                category: current.category,
                price: current.price,
                location: current.location,
                status: .open,
                yearsActive: current.yearsActive,
                photoURL: current.photoURL,
                voiceStoryURL: current.voiceStoryURL,
                description: current.description
            )
        }
    }

    func confirmGone(for stall: Stall) {
        update(stallID: stall.id) { current in
            Stall(
                id: current.id,
                name: current.name,
                ownerName: current.ownerName,
                category: current.category,
                price: current.price,
                location: current.location,
                status: .gone,
                yearsActive: current.yearsActive,
                photoURL: current.photoURL,
                voiceStoryURL: current.voiceStoryURL,
                description: current.description
            )
        }
    }

    func makeSelectedStall(_ stallID: UUID?) -> Stall? {
        guard let stallID else {
            return nil
        }

        return stalls.first(where: { $0.id == stallID })
    }

    private func update(stallID: UUID, transform: (Stall) -> Stall) {
        guard let index = stalls.firstIndex(where: { $0.id == stallID }) else {
            return
        }

        stalls[index] = transform(stalls[index])
    }
}
