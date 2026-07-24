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

struct PhotoAttachment: Identifiable, Codable, Hashable {
    let id: UUID
    var localFilename: String
    var thumbnailFilename: String
    var bundledResourceName: String?
    var remoteURL: URL?
    var createdAt: Date
    var caption: String?

    init(
        id: UUID = UUID(),
        localFilename: String,
        thumbnailFilename: String,
        bundledResourceName: String? = nil,
        remoteURL: URL? = nil,
        createdAt: Date = .now,
        caption: String? = nil
    ) {
        self.id = id
        self.localFilename = localFilename
        self.thumbnailFilename = thumbnailFilename
        self.bundledResourceName = bundledResourceName
        self.remoteURL = remoteURL
        self.createdAt = createdAt
        self.caption = caption
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

struct AppUser: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var role: AppRole
    var points: Int
    var rank: String
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
