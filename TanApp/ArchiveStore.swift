//
//  ArchiveStore.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import Foundation
import CoreLocation

@MainActor
final class ArchiveStore: ObservableObject {
    @Published var user = MockArchiveData.currentUser
    @Published var archives = MockArchiveData.archives
    @Published var favoriteIDs: Set<UUID> = []
    @Published var isLoggedIn = false
    @Published var selectedRole: AppRole = .visitor
    @Published var selectedTab: AppTab = .map
    @Published var cloudState = "已连接云端档案库"
    @Published var mapFocusRequest: MapFocusRequest?

    private let cloudService: CloudArchiveService

    init(cloudService: CloudArchiveService) {
        self.cloudService = cloudService
        Task {
            await loadFromCloud()
        }
    }

    var currentUserArchives: [CityArchive] {
        archives.filter(\.isUserCreated)
    }

    var pointsFromContributions: Int {
        archives.reduce(0) { total, archive in
            total + archive.photos.filter { $0.contributorName == user.name }.map(\.likes).reduce(0, +) * 2
            + archive.comments.filter { $0.contributorName == user.name }.map(\.likes).reduce(0, +)
        }
    }

    func login(as role: AppRole) {
        selectedRole = role
        user.role = role
        isLoggedIn = true
    }

    func switchRole(to role: AppRole) {
        selectedRole = role
        user.role = role
        if role == .visitor && selectedTab == .build {
            selectedTab = .map
        }
        persist()
    }

    func searchArchives(query: String, category: ArchiveCategory?) -> [CityArchive] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return archives.filter { archive in
            let categoryMatches = category == nil || archive.category == category
            guard !trimmed.isEmpty else {
                return categoryMatches
            }

            let searchable = ([archive.name, archive.ownerName, archive.category.title, archive.priceOrService, archive.summary] + archive.tags).joined(separator: " ")
            return categoryMatches && searchable.localizedCaseInsensitiveContains(trimmed)
        }
    }

    func toggleFavorite(_ archive: CityArchive) {
        if favoriteIDs.contains(archive.id) {
            favoriteIDs.remove(archive.id)
        } else {
            favoriteIDs.insert(archive.id)
        }
        persist()
    }

    func addPhoto(to archive: CityArchive, caption: String) {
        updateArchive(archive.id) { item in
            item.photos.insert(PhotoEntry(contributorName: user.name, caption: caption, likes: 0), at: 0)
        }
    }

    func addComment(to archive: CityArchive, text: String) {
        updateArchive(archive.id) { item in
            item.comments.insert(CommentEntry(contributorName: user.name, text: text, likes: 0), at: 0)
        }
    }

    func likePhoto(_ photo: PhotoEntry, in archive: CityArchive) {
        updateArchive(archive.id) { item in
            guard let index = item.photos.firstIndex(where: { $0.id == photo.id }) else { return }
            guard !item.photos[index].likedByUserIDs.contains(user.id) else { return }
            item.photos[index].likes += 1
            item.photos[index].likedByUserIDs.append(user.id)
            if item.photos[index].contributorName == user.name {
                user.points += 2
            }
        }
    }

    func likeComment(_ comment: CommentEntry, in archive: CityArchive) {
        updateArchive(archive.id) { item in
            guard let index = item.comments.firstIndex(where: { $0.id == comment.id }) else { return }
            guard !item.comments[index].likedByUserIDs.contains(user.id) else { return }
            item.comments[index].likes += 1
            item.comments[index].likedByUserIDs.append(user.id)
            if item.comments[index].contributorName == user.name {
                user.points += 1
            }
        }
    }

    func hasLikedPhoto(_ photo: PhotoEntry) -> Bool {
        photo.likedByUserIDs.contains(user.id)
    }

    func hasLikedComment(_ comment: CommentEntry) -> Bool {
        comment.likedByUserIDs.contains(user.id)
    }

    func openArchive(_ archive: CityArchive, at coordinate: CLLocationCoordinate2D) {
        updateArchive(archive.id) { item in
            item.status = .open
            item.currentLocation = CoordinatePoint(coordinate)
            item.historicalStops.insert(RouteStop(title: "实时开摊点", appearedAt: "刚刚", coordinate: CoordinatePoint(coordinate)), at: 0)
        }
    }

    func closeArchive(_ archive: CityArchive) {
        updateArchive(archive.id) { item in
            item.status = .closed
        }
    }

    func saveDraft(_ draft: AIArchiveDraft) {
        let archive = CityArchive(
            name: draft.name,
            ownerName: draft.ownerName,
            category: draft.category,
            tags: draft.tags,
            priceOrService: draft.priceOrService,
            currentLocation: MockArchiveData.chengduCenter,
            status: .closed,
            yearsActive: draft.yearsActive,
            summary: draft.summary,
            craftProcess: draft.craftProcess,
            historicalStops: [],
            photos: [],
            comments: [],
            isUserCreated: true
        )
        archives.insert(archive, at: 0)
        selectedTab = .map
        persist()
    }

    func updateArchive(_ archive: CityArchive, with draft: AIArchiveDraft) {
        updateArchive(archive.id) { item in
            item.name = draft.name
            item.ownerName = draft.ownerName
            item.category = draft.category
            item.tags = draft.tags
            item.priceOrService = draft.priceOrService
            item.yearsActive = draft.yearsActive
            item.summary = draft.summary
            item.craftProcess = draft.craftProcess
        }
    }

    func navigateToArchiveOnMap(_ archive: CityArchive) {
        mapFocusRequest = MapFocusRequest(archiveID: archive.id)
        selectedTab = .map
    }

    func archive(with id: UUID) -> CityArchive? {
        archives.first(where: { $0.id == id })
    }

    private func updateArchive(_ id: UUID, mutate: (inout CityArchive) -> Void) {
        guard let index = archives.firstIndex(where: { $0.id == id }) else {
            return
        }
        mutate(&archives[index])
        persist()
    }

    private func loadFromCloud() async {
        do {
            let snapshot = try await cloudService.loadSnapshot()
            user = snapshot.user
            selectedRole = snapshot.user.role
            archives = snapshot.archives
            favoriteIDs = snapshot.favoriteIDs
            cloudState = "云端档案已同步"
        } catch {
            cloudState = "云端同步失败，正在使用本地缓存"
        }
    }

    private func persist() {
        let snapshot = ArchiveSnapshot(user: user, archives: archives, favoriteIDs: favoriteIDs)
        Task {
            do {
                try await cloudService.saveSnapshot(snapshot)
                cloudState = "云端档案已同步"
            } catch {
                cloudState = "云端同步失败，稍后重试"
            }
        }
    }
}

enum AppTab: Hashable {
    case map
    case discover
    case build
    case profile
}

struct MapFocusRequest: Hashable {
    let id = UUID()
    let archiveID: UUID
}
