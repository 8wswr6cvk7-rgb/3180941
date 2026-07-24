//
//  _180941Tests.swift
//  3180941Tests
//
//  Created by student01 on 2026/3/23.
//

import Testing
import MapKit
import UIKit
@testable import TanApp

struct _180941Tests {

    @Test func example() async throws {
        #expect(!MockArchiveData.archives.isEmpty)
        #expect(MockArchiveData.archives.allSatisfy { !$0.historicalStops.isEmpty })
    }

    @Test func competitionSeedKeepsTheFiveDemoArchives() async throws {
        let seed = MockArchiveData.competitionSeedArchives
        #expect(seed.count == 5)
        #expect(seed.first?.name == "张大爷糖油果子")
        #expect(seed.contains(where: { $0.name == "李爷爷三大炮" && $0.status == .atRisk }))
        #expect(seed.first?.statusConfirmations.isEmpty == false)
        #expect(seed.allSatisfy { $0.photos.first?.attachment?.bundledResourceName != nil })
        #expect(seed.first?.photos.count == 3)
        #expect(seed.first?.statusConfirmations.first?.attachment?.bundledResourceName == "seed_zhang_status.jpg")
    }

    @Test func competitionSeedBundledCoverLoadsThroughPhotoStorage() async throws {
        let attachment = try #require(MockArchiveData.competitionSeedArchives.first?.photos.first?.attachment)
        let storage = LocalPhotoStorageService()
        let image = await storage.loadImage(attachment, thumbnail: true)
        #expect(image != nil)
    }

    @Test @MainActor func roleLoginOpensTheCompetitionEntryTab() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = ArchiveStore(
            repository: LocalArchiveRepository(rootURL: directory),
            photoStorage: LocalPhotoStorageService(rootURL: directory)
        )

        store.login(as: .visitor)
        #expect(store.selectedTab == .discover)
        store.switchRole(to: .stallOwner)
        #expect(store.selectedTab == .map)
        store.switchRole(to: .visitor)
        #expect(store.selectedTab == .map)
    }

    @Test func archiveDetailRoutesKeepTheirRequestedSection() async throws {
        let archiveID = UUID()
        #expect(ArchiveDetailRoute.top(archiveID).initialSection == .top)
        #expect(ArchiveDetailRoute.community(archiveID).initialSection == .community)
        #expect(ArchiveDetailRoute.community(archiveID).archiveID == archiveID)
    }

    @Test @MainActor func discoveryKeywordsAndAvailableCategoriesHaveResults() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = ArchiveStore(
            repository: LocalArchiveRepository(rootURL: directory),
            photoStorage: LocalPhotoStorageService(rootURL: directory)
        )
        await Task.yield()

        for keyword in ArchiveStore.discoveryKeywords {
            #expect(!store.searchArchives(query: keyword, category: nil).isEmpty)
        }
        #expect(!store.searchArchives(query: "文殊院", category: nil).isEmpty)
        #expect(store.availableCategories.allSatisfy { category in
            store.archives.contains { $0.category == category }
        })
        #expect(!store.availableCategories.contains { category in
            !store.archives.contains { $0.category == category }
        })
    }

    @Test @MainActor func onlySuccessfulCommunityPublishingRecordsAVisit() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = ArchiveStore(
            repository: LocalArchiveRepository(rootURL: directory),
            photoStorage: LocalPhotoStorageService(rootURL: directory)
        )
        await Task.yield()
        store.login(as: .visitor)
        let archive = try #require(store.archives.first)
        let statusArchive = try #require(store.archives.dropFirst().first)

        _ = store.searchArchives(query: archive.name, category: nil)
        store.navigateToArchiveOnMap(archive)
        #expect(!store.visitedArchiveIDs.contains(archive.id))

        try await store.addComment(to: archive, text: "今天看到摊位了。", pendingImages: [])
        #expect(store.visitedArchiveIDs.contains(archive.id))
        let visitCount = store.visitedArchiveIDs.count
        try await store.addComment(to: archive, text: "再补一句。", pendingImages: [])
        #expect(store.visitedArchiveIDs.count == visitCount)

        #expect(!store.visitedArchiveIDs.contains(statusArchive.id))
        try await store.addStatusConfirmation(
            to: statusArchive,
            result: .stillThere,
            clue: "傍晚在原位置看到。",
            pendingImage: nil
        )
        #expect(store.visitedArchiveIDs.contains(statusArchive.id))
    }

    @Test func xilianGuideOriginUsesLiveLocationOnlyInsideChengduRange() async throws {
        let chengdu = CLLocationCoordinate2D(latitude: 30.67, longitude: 104.06)
        let beijing = CLLocationCoordinate2D(latitude: 39.90, longitude: 116.40)

        #expect(XilianGuideOriginPolicy.decision(for: chengdu).source == .liveLocation)
        #expect(XilianGuideOriginPolicy.decision(for: beijing).source == .chengduDemoLocation)
        #expect(XilianGuideOriginPolicy.decision(for: nil).source == .chengduDemoLocation)
    }

    @Test func xilianQuickQuestionKeepsLocalFallback() async throws {
        let reply = XilianCopy.reply(
            to: .nearby,
            selectedArchive: nil,
            nearbyArchives: MockArchiveData.archives
        )

        #expect(reply.contains("伙伴"))
        #expect(reply.contains("\(MockArchiveData.archives.count)"))
    }

    @Test @MainActor func xilianComposerPreservesChineseInput() async throws {
        let viewModel = XilianChatViewModel(
            selectedArchive: nil,
            nearbyArchives: MockArchiveData.archives,
            currentPage: .map
        )
        let question = "帮我写代码"

        viewModel.inputText = question
        #expect(viewModel.canSend)
        viewModel.send()

        #expect(viewModel.inputText.isEmpty)
        #expect(viewModel.messages.contains { $0.role == .user && $0.text == question })
    }

    @Test func xilianRedirectsClearlyUnrelatedQuestions() async throws {
        let reply = try await XilianChatAgent().reply(
            to: "帮我写代码",
            selectedArchive: nil,
            nearbyArchives: MockArchiveData.archives,
            currentPage: .map
        )

        #expect(reply == "伙伴，这个问题我可能帮不上太多。不过我可以陪你看看附近的摊位故事。")
    }

    @Test func xilianCoordinateInterpolationReachesDestination() async throws {
        let start = MockArchiveData.chengduCenter.coordinate
        let end = XilianCoordinateInterpolator.offsetCoordinate(
            start,
            latitudeOffset: 0.001,
            longitudeOffset: 0.001
        )
        let route = XilianCoordinateInterpolator.interpolateCoordinates(from: start, to: end, steps: 30)

        #expect(route.count == 30)
        #expect(XilianCoordinateInterpolator.coordinatesNearlyEqual(route.last, end))
        #expect(route[0].latitude > start.latitude)
    }

    @Test func xilianRouteHelpersConvertAndBuildDistancePath() async throws {
        var coordinates = XilianRouteHelpers.fallbackLine(
            from: MockArchiveData.chengduCenter.coordinate,
            to: MockArchiveData.archives[0].currentLocation.coordinate,
            steps: 120
        )
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        let extracted = XilianRouteHelpers.coordinates(from: polyline)
        let path = XilianRoutePath(coordinates: extracted)

        #expect(extracted.count == coordinates.count)
        #expect(path.totalDistance > 0)
        if let first = path.coordinates.first, let expectedFirst = coordinates.first {
            #expect(XilianCoordinateInterpolator.coordinatesNearlyEqual(first, expectedFirst))
        }
        if let last = path.coordinates.last, let expectedLast = coordinates.last {
            #expect(XilianCoordinateInterpolator.coordinatesNearlyEqual(last, expectedLast))
        }
    }

    @Test func xilianRoutePathInterpolatesInsideCurrentSegment() async throws {
        let start = CLLocationCoordinate2D(latitude: 30.6500, longitude: 104.0600)
        let corner = CLLocationCoordinate2D(latitude: 30.6500, longitude: 104.0700)
        let end = CLLocationCoordinate2D(latitude: 30.6600, longitude: 104.0700)
        let path = XilianRoutePath(coordinates: [start, corner, end])

        let firstSegmentMidpoint = path.coordinate(atDistance: path.totalDistance * 0.25)
        let secondSegmentMidpoint = path.coordinate(atDistance: path.totalDistance * 0.75)

        #expect(abs(firstSegmentMidpoint.latitude - start.latitude) < 0.0001)
        #expect(firstSegmentMidpoint.longitude > start.longitude)
        #expect(firstSegmentMidpoint.longitude < corner.longitude)
        #expect(abs(secondSegmentMidpoint.longitude - corner.longitude) < 0.0001)
        #expect(secondSegmentMidpoint.latitude > corner.latitude)
        #expect(secondSegmentMidpoint.latitude < end.latitude)
    }

    @Test func xilianRoutePathClampsProgressAndHandlesDegenerateRoutes() async throws {
        let point = CLLocationCoordinate2D(latitude: 30.6500, longitude: 104.0600)
        let end = CLLocationCoordinate2D(latitude: 30.6510, longitude: 104.0610)
        let path = XilianRoutePath(coordinates: [point, end])

        #expect(XilianCoordinateInterpolator.coordinatesNearlyEqual(path.coordinate(atProgress: -1), point))
        #expect(XilianCoordinateInterpolator.coordinatesNearlyEqual(path.coordinate(atProgress: 2), end))

        let emptyPath = XilianRoutePath(coordinates: [])
        #expect(!CLLocationCoordinate2DIsValid(emptyPath.coordinate(atProgress: 0.5)))

        let singlePointPath = XilianRoutePath(coordinates: [point])
        #expect(XilianCoordinateInterpolator.coordinatesNearlyEqual(singlePointPath.coordinate(atProgress: 0.5), point))
    }

    @Test func xilianRoutePathUsesDistanceInsteadOfCoordinateIndex() async throws {
        let start = CLLocationCoordinate2D(latitude: 30.6500, longitude: 104.0600)
        let shortSegmentEnd = CLLocationCoordinate2D(latitude: 30.6500, longitude: 104.0610)
        let end = CLLocationCoordinate2D(latitude: 30.6500, longitude: 104.0710)
        let path = XilianRoutePath(coordinates: [start, shortSegmentEnd, end])

        let midpoint = path.coordinate(atProgress: 0.5)
        #expect(midpoint.longitude > 104.065)
        #expect(midpoint.longitude < 104.066)
    }

    @Test func xilianRoutePathInterpolatesAcrossTheDateLine() async throws {
        let start = CLLocationCoordinate2D(latitude: 0, longitude: 179.8)
        let end = CLLocationCoordinate2D(latitude: 0, longitude: -179.8)
        let midpoint = XilianRoutePath.interpolatedCoordinate(from: start, to: end, progress: 0.5)

        #expect(abs(abs(midpoint.longitude) - 180) < 0.001)
    }

    @Test @MainActor func xilianRouteMovementRestartCancelsPreviousArrival() async throws {
        let controller = XilianRouteMovementController(animationDurationOverride: { _ in 0.05 })
        let start = CLLocationCoordinate2D(latitude: 30.6500, longitude: 104.0600)
        let firstEnd = CLLocationCoordinate2D(latitude: 30.6510, longitude: 104.0610)
        let secondEnd = CLLocationCoordinate2D(latitude: 30.6520, longitude: 104.0620)
        var arrivalCount = 0

        controller.startMovingAlongRoute(
            coordinates: [start, firstEnd],
            arrivalMessage: "",
            arrivalState: .happy,
            archiveID: UUID()
        ) {
            arrivalCount += 1
        }
        controller.startMovingAlongRoute(
            coordinates: [start, secondEnd],
            arrivalMessage: "",
            arrivalState: .happy,
            archiveID: UUID()
        ) {
            arrivalCount += 1
        }

        try await Task.sleep(nanoseconds: 150_000_000)

        #expect(arrivalCount == 1)
        #expect(controller.guideState == .arrived)
        #expect(XilianCoordinateInterpolator.coordinatesNearlyEqual(controller.currentCoordinate, secondEnd))
    }

    @Test @MainActor func xilianRouteMovementClearPreventsArrivalCallback() async throws {
        let controller = XilianRouteMovementController(animationDurationOverride: { _ in 0.08 })
        let start = CLLocationCoordinate2D(latitude: 30.6500, longitude: 104.0600)
        let end = CLLocationCoordinate2D(latitude: 30.6520, longitude: 104.0620)
        var arrivalCount = 0

        controller.startMovingAlongRoute(
            coordinates: [start, end],
            arrivalMessage: "",
            arrivalState: .happy,
            archiveID: UUID()
        ) {
            arrivalCount += 1
        }
        controller.clear()

        try await Task.sleep(nanoseconds: 150_000_000)

        #expect(arrivalCount == 0)
        #expect(controller.guideState == .idle)
    }

    @Test func localArchiveRepositoryRestoresSnapshot() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let repository = LocalArchiveRepository(rootURL: directory)
        var snapshot = try await repository.loadSnapshot()
        snapshot.favoriteIDs = [snapshot.archives[0].id]
        snapshot.visitedArchiveIDs = [snapshot.archives[0].id]
        try await repository.saveSnapshot(snapshot)

        let restored = try await repository.loadSnapshot()
        #expect(restored.favoriteIDs == snapshot.favoriteIDs)
        #expect(restored.visitedArchiveIDs == snapshot.visitedArchiveIDs)
        #expect(restored.archives.count == snapshot.archives.count)
    }

    @Test func localPhotoStorageSavesLoadsAndDeletesImage() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let storage = LocalPhotoStorageService(rootURL: directory)
        let image = UIGraphicsImageRenderer(size: CGSize(width: 2_800, height: 1_800)).image { context in
            UIColor.orange.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2_800, height: 1_800))
        }

        let attachment = try await storage.saveImage(image, caption: "测试图片")
        let fullImage = await storage.loadImage(attachment, thumbnail: false)
        let thumbnail = await storage.loadImage(attachment, thumbnail: true)
        #expect(fullImage != nil)
        #expect(thumbnail != nil)

        try await storage.deletePhoto(attachment)
        let deletedImage = await storage.loadImage(attachment, thumbnail: false)
        #expect(deletedImage == nil)
    }

    @Test func commentsLimitAttachmentsToThree() async throws {
        let attachments = (0..<4).map { index in
            PhotoAttachment(
                localFilename: "\(index).jpg",
                thumbnailFilename: "\(index)_thumb.jpg"
            )
        }
        let comment = CommentEntry(contributorName: "测试用户", text: "现场线索", imageAttachments: attachments, likes: 0)
        #expect(comment.imageAttachments.count == 3)
    }

    @Test func metricIconOptionsUseChineseLabelsWithoutChangingStoredSymbols() {
        #expect(MetricIconOption.friendly.title == "入门友好")
        #expect(MetricIconOption.friendly.symbol == "hand.thumbsup.fill")
        #expect(MetricIconOption.tools.symbol == "hammer.fill")
        #expect(MetricIconOption.option(for: "camera.fill") == .camera)
        #expect(MetricIconOption.option(for: "historical.unknown.symbol") == nil)
    }

    @Test func speechTranscriptMergesWithoutClearingExistingInput() {
        #expect(
            SpeechTranscriptMerger.merge(
                existing: "我在玉林路出摊",
                transcript: "已经二十多年"
            ) == "我在玉林路出摊 已经二十多年"
        )
        #expect(
            SpeechTranscriptMerger.merge(
                existing: "我在玉林路出摊。",
                transcript: "已经二十多年"
            ) == "我在玉林路出摊。已经二十多年"
        )
        #expect(SpeechTranscriptMerger.merge(existing: "原有文字", transcript: "   ") == "原有文字")
    }

    @Test @MainActor func speechRecognitionControllerAcceptsPartialAndFinalResults() async {
        let service = FakeSpeechRecognitionService()
        let controller = SpeechRecognitionController(service: service)

        controller.start(dialect: .chengdu)
        #expect(service.startCount == 1)
        #expect(controller.state == .requestingPermission)

        service.emit(.connecting)
        service.emit(.ready)
        service.emit(.partial(sentenceID: 0, text: "我在玉林路"))
        await Task.yield()
        #expect(controller.liveTranscript == "我在玉林路")

        service.emit(.final(sentenceID: 0, text: "我在玉林路出摊。"))
        service.emit(.final(sentenceID: 1, text: "已经二十多年。"))
        service.emit(.finished)
        await Task.yield()

        #expect(controller.state == .idle)
        #expect(controller.completion?.text == "我在玉林路出摊。已经二十多年。")
        #expect(service.stopCount == 0)
    }

    @Test @MainActor func speechRecognitionControllerBlocksDuplicateStartAndCancelsCleanly() async {
        let service = FakeSpeechRecognitionService()
        let controller = SpeechRecognitionController(service: service)

        controller.start(dialect: .zigong)
        controller.start(dialect: .mandarin)
        #expect(service.startCount == 1)

        service.emit(.ready)
        service.emit(.partial(sentenceID: 0, text: "最后一段有效转写"))
        await Task.yield()
        controller.cancel(preservingTranscript: true)

        #expect(service.cancelCount == 1)
        #expect(controller.state == .idle)
        #expect(controller.completion?.text == "最后一段有效转写")
        #expect(controller.liveTranscript.isEmpty)
    }

}

private final class FakeSpeechRecognitionService: SpeechRecognitionService {
    var eventHandler: ((SpeechRecognitionEvent) -> Void)?
    private(set) var startCount = 0
    private(set) var stopCount = 0
    private(set) var cancelCount = 0

    func start(dialect: ArchiveDialect) {
        startCount += 1
    }

    func stop() {
        stopCount += 1
    }

    func cancel() {
        cancelCount += 1
    }

    func emit(_ event: SpeechRecognitionEvent) {
        eventHandler?(event)
    }
}
