import Foundation
import CoreLocation
import UIKit

@MainActor
final class ArchiveStore: ObservableObject {
    static let discoveryKeywords = ["糖油果子", "三大炮", "蜀绣", "补鞋", "消失预警"]

    @Published var user = MockArchiveData.currentUser
    @Published var archives = MockArchiveData.competitionSeedArchives
    @Published var favoriteIDs: Set<UUID> = []
    @Published var isLoggedIn = false
    @Published var selectedRole: AppRole = .visitor
    @Published var selectedTab: AppTab = .map
    @Published var cloudState = "正在载入本地档案"
    @Published var mapFocusRequest: MapFocusRequest?
    @Published var visitedArchiveIDs: Set<UUID> = []
    @Published var litArchiveIDs: Set<UUID> = []

    private let repository: ArchiveRepository
    private let photoStorage: PhotoStorageService

    init(repository: ArchiveRepository, photoStorage: PhotoStorageService) {
        self.repository = repository
        self.photoStorage = photoStorage
        Task { await loadFromRepository() }
    }

    var currentUserArchives: [CityArchive] {
        archives.filter(\.isUserCreated)
    }

    var availableCategories: [ArchiveCategory] {
        ArchiveCategory.allCases.filter { category in
            archives.contains { $0.category == category }
        }
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
        selectedTab = defaultTab(for: role)
        persist()
    }

    func switchRole(to role: AppRole) {
        selectedRole = role
        user.role = role
        selectedTab = .map
        persist()
    }

    func searchArchives(query: String, category: ArchiveCategory?) -> [CityArchive] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return archives.filter { archive in
            let categoryMatches = category == nil || archive.category == category
            guard !trimmed.isEmpty else { return categoryMatches }
            let searchable = (
                [
                    archive.name,
                    archive.ownerName,
                    archive.category.title,
                    archive.status.title,
                    archive.priceOrService,
                    archive.summary
                ]
                + archive.tags
                + archive.historicalStops.map(\.title)
            ).joined(separator: " ")
            return categoryMatches && searchable.localizedCaseInsensitiveContains(trimmed)
        }
    }

    func toggleFavorite(_ archive: CityArchive) {
        if favoriteIDs.contains(archive.id) {
            favoriteIDs.remove(archive.id)
        } else {
            favoriteIDs.insert(archive.id)
            markArchiveLit(archive, shouldPersist: false)
        }
        persist()
    }

    func addPhoto(to archive: CityArchive, caption: String, pendingImage: PendingImage) async throws {
        let attachment = try await photoStorage.saveImage(pendingImage.image, caption: caption)
        markArchiveLit(archive, shouldPersist: false)
        updateArchive(archive.id, shouldPersist: false) { item in
            item.photos.insert(PhotoEntry(contributorName: user.name, caption: caption, attachment: attachment, likes: 0), at: 0)
        }
        persist()
    }

    func addComment(to archive: CityArchive, text: String, pendingImages: [PendingImage]) async throws {
        let attachments = try await saveAttachments(from: Array(pendingImages.prefix(3)), caption: text)
        markArchiveLit(archive, shouldPersist: false)
        if selectedRole == .visitor {
            markArchiveVisited(archive, shouldPersist: false)
        }
        updateArchive(archive.id, shouldPersist: false) { item in
            item.comments.insert(
                CommentEntry(contributorName: user.name, text: text, imageAttachments: attachments, likes: 0),
                at: 0
            )
        }
        persist()
    }

    func addStatusConfirmation(
        to archive: CityArchive,
        result: StallConfirmationResult,
        clue: String,
        pendingImage: PendingImage?
    ) async throws {
        let attachment: PhotoAttachment?
        if let pendingImage {
            attachment = try await photoStorage.saveImage(pendingImage.image, caption: clue)
        } else {
            attachment = nil
        }
        markArchiveLit(archive, shouldPersist: false)
        if selectedRole == .visitor {
            markArchiveVisited(archive, shouldPersist: false)
        }
        updateArchive(archive.id, shouldPersist: false) { item in
            item.statusConfirmations.insert(
                StallStatusConfirmation(
                    contributorName: user.name,
                    result: result,
                    clue: clue,
                    attachment: attachment
                ),
                at: 0
            )
        }
        persist()
    }

    func deletePhoto(_ photo: PhotoEntry, in archive: CityArchive) async {
        if let attachment = photo.attachment { try? await photoStorage.deletePhoto(attachment) }
        updateArchive(archive.id) { item in
            item.photos.removeAll { $0.id == photo.id }
        }
    }

    func deleteComment(_ comment: CommentEntry, in archive: CityArchive) async {
        for attachment in comment.imageAttachments { try? await photoStorage.deletePhoto(attachment) }
        updateArchive(archive.id) { item in
            item.comments.removeAll { $0.id == comment.id }
        }
    }

    func deleteStatusConfirmation(_ confirmation: StallStatusConfirmation, in archive: CityArchive) async {
        if let attachment = confirmation.attachment { try? await photoStorage.deletePhoto(attachment) }
        updateArchive(archive.id) { item in
            item.statusConfirmations.removeAll { $0.id == confirmation.id }
        }
    }

    func image(for attachment: PhotoAttachment, thumbnail: Bool = true) async -> UIImage? {
        await photoStorage.loadImage(attachment, thumbnail: thumbnail)
    }

    func likePhoto(_ photo: PhotoEntry, in archive: CityArchive) {
        guard !photo.likedByUserIDs.contains(user.id) else { return }
        markArchiveLit(archive, shouldPersist: false)
        updateArchive(archive.id) { item in
            guard let index = item.photos.firstIndex(where: { $0.id == photo.id }) else { return }
            guard !item.photos[index].likedByUserIDs.contains(user.id) else { return }
            item.photos[index].likes += 1
            item.photos[index].likedByUserIDs.append(user.id)
            if item.photos[index].contributorName == user.name { user.points += 2 }
        }
    }

    func likeComment(_ comment: CommentEntry, in archive: CityArchive) {
        guard !comment.likedByUserIDs.contains(user.id) else { return }
        markArchiveLit(archive, shouldPersist: false)
        updateArchive(archive.id) { item in
            guard let index = item.comments.firstIndex(where: { $0.id == comment.id }) else { return }
            guard !item.comments[index].likedByUserIDs.contains(user.id) else { return }
            item.comments[index].likes += 1
            item.comments[index].likedByUserIDs.append(user.id)
            if item.comments[index].contributorName == user.name { user.points += 1 }
        }
    }

    func hasLikedPhoto(_ photo: PhotoEntry) -> Bool { photo.likedByUserIDs.contains(user.id) }
    func hasLikedComment(_ comment: CommentEntry) -> Bool { comment.likedByUserIDs.contains(user.id) }

    func openArchive(_ archive: CityArchive, at coordinate: CLLocationCoordinate2D) {
        updateArchive(archive.id) { item in
            item.status = .open
            item.currentLocation = CoordinatePoint(coordinate)
            item.historicalStops.insert(RouteStop(title: "实时开摊点", appearedAt: "刚刚", coordinate: CoordinatePoint(coordinate)), at: 0)
        }
    }

    func closeArchive(_ archive: CityArchive) {
        updateArchive(archive.id) { $0.status = .closed }
    }

    func saveDraft(_ draft: AIArchiveDraft, coverImage: PendingImage?) async throws {
        let coverAttachment: PhotoAttachment?
        if let coverImage {
            coverAttachment = try await photoStorage.saveImage(coverImage.image, caption: "摊主建档现场照片")
        } else {
            coverAttachment = nil
        }
        let initialPhotos = coverAttachment.map {
            [PhotoEntry(contributorName: user.name, caption: "摊主建档现场照片", attachment: $0, likes: 0)]
        } ?? []
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
            photos: initialPhotos,
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

    func updateArchive(_ archive: CityArchive, with draft: AIArchiveDraft, status: ArchiveStatus, historicalStops: [RouteStop]) {
        updateArchive(archive.id) { item in
            item.name = draft.name
            item.ownerName = draft.ownerName
            item.category = draft.category
            item.tags = draft.tags
            item.priceOrService = draft.priceOrService
            item.status = status
            item.yearsActive = draft.yearsActive
            item.summary = draft.summary
            item.craftProcess = draft.craftProcess
            item.historicalStops = historicalStops
        }
    }

    func navigateToArchiveOnMap(_ archive: CityArchive) {
        mapFocusRequest = MapFocusRequest(archiveID: archive.id)
        selectedTab = .map
    }

    func archive(with id: UUID) -> CityArchive? { archives.first(where: { $0.id == id }) }

    func markArchiveVisited(_ archive: CityArchive, shouldPersist: Bool = true) {
        visitedArchiveIDs.insert(archive.id)
        if shouldPersist { persist() }
    }

    func markArchiveLit(_ archive: CityArchive, shouldPersist: Bool = true) {
        litArchiveIDs.insert(archive.id)
        if shouldPersist { persist() }
    }

#if DEBUG
    func resetCompetitionDemoData() async {
        let attachments = archives.flatMap { archive in
            archive.photos.compactMap(\.attachment)
                + archive.comments.flatMap(\.imageAttachments)
                + archive.statusConfirmations.compactMap(\.attachment)
        }
        for attachment in attachments {
            try? await photoStorage.deletePhoto(attachment)
        }
        clearArchiveDetailContentCache()

        user = MockArchiveData.currentUser
        archives = MockArchiveData.competitionSeedArchives
        favoriteIDs = Set(MockArchiveData.competitionSeedArchives.prefix(3).map(\.id))
        visitedArchiveIDs = []
        litArchiveIDs = []
        selectedRole = .visitor
        selectedTab = .discover
        mapFocusRequest = nil

        let snapshot = ArchiveSnapshot(
            user: user,
            archives: archives,
            favoriteIDs: favoriteIDs,
            visitedArchiveIDs: visitedArchiveIDs,
            litArchiveIDs: litArchiveIDs
        )
        do {
            try await repository.saveSnapshot(snapshot)
            cloudState = "比赛演示数据已恢复"
        } catch {
            cloudState = "演示数据恢复失败，请重试"
        }
    }
#endif

    private func saveAttachments(from pendingImages: [PendingImage], caption: String) async throws -> [PhotoAttachment] {
        var attachments: [PhotoAttachment] = []
        do {
            for pending in pendingImages {
                attachments.append(try await photoStorage.saveImage(pending.image, caption: caption))
            }
            return attachments
        } catch {
            for attachment in attachments { try? await photoStorage.deletePhoto(attachment) }
            throw error
        }
    }

    private func updateArchive(_ id: UUID, shouldPersist: Bool = true, mutate: (inout CityArchive) -> Void) {
        guard let index = archives.firstIndex(where: { $0.id == id }) else { return }
        mutate(&archives[index])
        if shouldPersist { persist() }
    }

    private func loadFromRepository() async {
        do {
            let snapshot = try await repository.loadSnapshot()
            user = snapshot.user
            selectedRole = snapshot.user.role
            archives = snapshot.archives
            favoriteIDs = snapshot.favoriteIDs
            visitedArchiveIDs = snapshot.visitedArchiveIDs
            litArchiveIDs = snapshot.litArchiveIDs
            cloudState = "本地档案已恢复"
        } catch {
            cloudState = "本地档案读取失败，正在使用演示数据"
        }
    }

    private func persist() {
        let snapshot = ArchiveSnapshot(
            user: user,
            archives: archives,
            favoriteIDs: favoriteIDs,
            visitedArchiveIDs: visitedArchiveIDs,
            litArchiveIDs: litArchiveIDs
        )
        Task {
            do {
                try await repository.saveSnapshot(snapshot)
                cloudState = "本地档案已保存"
            } catch {
                cloudState = "本地档案保存失败，请稍后重试"
            }
        }
    }

    private func defaultTab(for role: AppRole) -> AppTab {
        role == .visitor ? .discover : .build
    }
}

enum AppTab: Hashable {
    case map, discover, build, profile
}

struct MapFocusRequest: Hashable {
    let id = UUID()
    let archiveID: UUID
}
