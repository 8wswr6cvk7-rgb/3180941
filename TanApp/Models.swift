//
//  Models.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import Foundation
import CoreLocation

enum AppRole: String, CaseIterable, Codable {
    case visitor
    case stallOwner

    var title: String {
        switch self {
        case .visitor:
            return "用户"
        case .stallOwner:
            return "摊户"
        }
    }
}

enum ArchiveStatus: String, Codable, CaseIterable {
    case open
    case closed
    case atRisk
}

enum ArchiveCategory: String, Codable, CaseIterable {
    case snack
    case produce
    case heritageCraft
    case oldTrade
    case cultureExperience
    case other
}

struct CoordinatePoint: Codable, Hashable {
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    init(_ coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}

struct RouteStop: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var appearedAt: String
    var coordinate: CoordinatePoint

    init(id: UUID = UUID(), title: String, appearedAt: String, coordinate: CoordinatePoint) {
        self.id = id
        self.title = title
        self.appearedAt = appearedAt
        self.coordinate = coordinate
    }
}

enum AttachmentMediaType: String, Codable, Hashable {
    case image
    case video
}

struct PhotoAttachment: Identifiable, Codable, Hashable {
    let id: UUID
    var localFilename: String
    var thumbnailFilename: String
    var bundledResourceName: String?
    var remoteURL: URL?
    var createdAt: Date
    var caption: String?
    /// Optional so snapshots created before video support continue to decode.
    /// A missing value always represents an image.
    var mediaType: AttachmentMediaType?
    var videoDuration: TimeInterval?

    var resolvedMediaType: AttachmentMediaType {
        mediaType ?? .image
    }

    init(
        id: UUID = UUID(),
        localFilename: String,
        thumbnailFilename: String,
        bundledResourceName: String? = nil,
        remoteURL: URL? = nil,
        createdAt: Date = .now,
        caption: String? = nil,
        mediaType: AttachmentMediaType? = nil,
        videoDuration: TimeInterval? = nil
    ) {
        self.id = id
        self.localFilename = localFilename
        self.thumbnailFilename = thumbnailFilename
        self.bundledResourceName = bundledResourceName
        self.remoteURL = remoteURL
        self.createdAt = createdAt
        self.caption = caption
        self.mediaType = mediaType
        self.videoDuration = videoDuration
    }
}

struct PhotoEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var contributorName: String
    var caption: String
    var attachment: PhotoAttachment?
    var createdAt: Date
    var likes: Int
    var likedByUserIDs: [UUID]

    init(
        id: UUID = UUID(),
        contributorName: String,
        caption: String,
        attachment: PhotoAttachment? = nil,
        createdAt: Date = .now,
        likes: Int,
        likedByUserIDs: [UUID] = []
    ) {
        self.id = id
        self.contributorName = contributorName
        self.caption = caption
        self.attachment = attachment
        self.createdAt = createdAt
        self.likes = likes
        self.likedByUserIDs = likedByUserIDs
    }
}

struct CommentEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var contributorName: String
    var text: String
    var imageAttachments: [PhotoAttachment]
    var createdAt: Date
    var likes: Int
    var likedByUserIDs: [UUID]

    init(
        id: UUID = UUID(),
        contributorName: String,
        text: String,
        imageAttachments: [PhotoAttachment] = [],
        createdAt: Date = .now,
        likes: Int,
        likedByUserIDs: [UUID] = []
    ) {
        self.id = id
        self.contributorName = contributorName
        self.text = text
        self.imageAttachments = Array(imageAttachments.prefix(3))
        self.createdAt = createdAt
        self.likes = likes
        self.likedByUserIDs = likedByUserIDs
    }
}

enum StallConfirmationResult: String, Codable, CaseIterable, Hashable {
    case stillThere
    case notSeen
    case locationChanged

    var title: String {
        switch self {
        case .stillThere: return "在原处看到该摊"
        case .notSeen: return "暂未见到该摊"
        case .locationChanged: return "摊位位置有变化"
        }
    }

    var symbol: String {
        switch self {
        case .stillThere: return "checkmark.seal.fill"
        case .notSeen: return "eye.slash.fill"
        case .locationChanged: return "arrow.triangle.turn.up.right.diamond.fill"
        }
    }
}

struct StallStatusConfirmation: Identifiable, Codable, Hashable {
    let id: UUID
    var contributorName: String
    var result: StallConfirmationResult
    var clue: String
    var attachment: PhotoAttachment?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        contributorName: String,
        result: StallConfirmationResult,
        clue: String,
        attachment: PhotoAttachment? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.contributorName = contributorName
        self.result = result
        self.clue = clue
        self.attachment = attachment
        self.createdAt = createdAt
    }
}

struct CityArchive: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var ownerName: String
    var category: ArchiveCategory
    var tags: [String]
    var priceOrService: String
    var currentLocation: CoordinatePoint
    var status: ArchiveStatus
    var yearsActive: Int
    var summary: String
    var craftProcess: [String]
    var historicalStops: [RouteStop]
    var photos: [PhotoEntry]
    var comments: [CommentEntry]
    var statusConfirmations: [StallStatusConfirmation]
    var isUserCreated: Bool

    init(
        id: UUID = UUID(),
        name: String,
        ownerName: String,
        category: ArchiveCategory,
        tags: [String],
        priceOrService: String,
        currentLocation: CoordinatePoint,
        status: ArchiveStatus,
        yearsActive: Int,
        summary: String,
        craftProcess: [String],
        historicalStops: [RouteStop],
        photos: [PhotoEntry],
        comments: [CommentEntry],
        statusConfirmations: [StallStatusConfirmation] = [],
        isUserCreated: Bool = false
    ) {
        self.id = id
        self.name = name
        self.ownerName = ownerName
        self.category = category
        self.tags = tags
        self.priceOrService = priceOrService
        self.currentLocation = currentLocation
        self.status = status
        self.yearsActive = yearsActive
        self.summary = summary
        self.craftProcess = craftProcess
        self.historicalStops = historicalStops
        self.photos = photos
        self.comments = comments
        self.statusConfirmations = statusConfirmations
        self.isUserCreated = isUserCreated
    }
}

enum ArchiveAttentionLevel: Equatable {
    case stable
    case watch
    case atRisk
    case insufficientEvidence
}

struct ArchiveAttentionAssessment: Equatable {
    let level: ArchiveAttentionLevel
    let reasons: [String]
}

enum ArchiveDisappearanceRiskEvaluator {
    private static let day: TimeInterval = 24 * 60 * 60

    static func evaluate(
        _ archive: CityArchive,
        now: Date = .now
    ) -> ArchiveAttentionAssessment {
        let confirmations = archive.statusConfirmations.sorted { $0.createdAt > $1.createdAt }
        let latestStillThere = confirmations.first { $0.result == .stillThere }
        let negativeAfterLatestStillThere = confirmations.filter { confirmation in
            guard confirmation.result != .stillThere else { return false }
            guard let latestStillThere else { return true }
            return confirmation.createdAt > latestStillThere.createdAt
        }
        let recentNotSeen = negativeAfterLatestStillThere.filter {
            $0.result == .notSeen && age(of: $0.createdAt, at: now) <= 30 * day
        }
        let recentLocationChange = negativeAfterLatestStillThere.first {
            $0.result == .locationChanged && age(of: $0.createdAt, at: now) <= 30 * day
        }

        if let latestStillThere,
           age(of: latestStillThere.createdAt, at: now) <= 14 * day,
           negativeAfterLatestStillThere.isEmpty {
            return ArchiveAttentionAssessment(
                level: .stable,
                reasons: ["最近 14 天内有社区成员确认仍在"]
            )
        }

        if recentNotSeen.count >= 2 {
            return ArchiveAttentionAssessment(
                level: .atRisk,
                reasons: [
                    "近 30 天有 \(recentNotSeen.count) 次暂未见到",
                    latestStillThere.map {
                        "最近一次确认仍在距今 \(wholeDaysSince($0.createdAt, at: now)) 天"
                    } ?? "暂时没有确认仍在的社区线索"
                ]
            )
        }

        if let latestStillThere,
           age(of: latestStillThere.createdAt, at: now) > 60 * day,
           !recentNotSeen.isEmpty {
            return ArchiveAttentionAssessment(
                level: .atRisk,
                reasons: [
                    "最近一次确认仍在距今 \(wholeDaysSince(latestStillThere.createdAt, at: now)) 天",
                    "近 30 天又有社区成员暂未见到"
                ]
            )
        }

        if recentLocationChange != nil {
            return ArchiveAttentionAssessment(
                level: .watch,
                reasons: ["最近有摊位位置变化线索，等待新的现场确认"]
            )
        }

        if !recentNotSeen.isEmpty {
            return ArchiveAttentionAssessment(
                level: .watch,
                reasons: ["近期有一次暂未见到，尚不足以形成消失预警"]
            )
        }

        if archive.status == .atRisk {
            return ArchiveAttentionAssessment(
                level: .atRisk,
                reasons: ["社区已将这份档案标记为持续关注"]
            )
        }

        return ArchiveAttentionAssessment(
            level: .insufficientEvidence,
            reasons: ["社区状态线索不足，等待进一步确认"]
        )
    }

    private static func age(of date: Date, at now: Date) -> TimeInterval {
        max(0, now.timeIntervalSince(date))
    }

    private static func wholeDaysSince(_ date: Date, at now: Date) -> Int {
        max(0, Int(age(of: date, at: now) / day))
    }
}

extension CityArchive {
    var attentionAssessment: ArchiveAttentionAssessment {
        ArchiveDisappearanceRiskEvaluator.evaluate(self)
    }

    var presentationStatus: ArchiveStatus {
        switch attentionAssessment.level {
        case .atRisk:
            return .atRisk
        case .stable where status == .atRisk:
            return .closed
        default:
            return status
        }
    }
}

struct AppUser: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var role: AppRole
    var points: Int
    var rank: String
    var avatarAttachment: PhotoAttachment? = nil
}

struct AIArchiveDraft: Codable, Hashable {
    var name: String
    var ownerName: String
    var category: ArchiveCategory
    var tags: [String]
    var priceOrService: String
    var yearsActive: Int
    var summary: String
    var craftProcess: [String]
}

extension AIArchiveDraft {
    init(archive: CityArchive) {
        name = archive.name
        ownerName = archive.ownerName
        category = archive.category
        tags = archive.tags
        priceOrService = archive.priceOrService
        yearsActive = archive.yearsActive
        summary = archive.summary
        craftProcess = archive.craftProcess
    }
}
