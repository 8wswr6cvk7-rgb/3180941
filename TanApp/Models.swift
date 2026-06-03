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

struct PhotoEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var contributorName: String
    var caption: String
    var imageData: Data?
    var likes: Int
    var likedByUserIDs: [UUID]

    init(id: UUID = UUID(), contributorName: String, caption: String, imageData: Data? = nil, likes: Int, likedByUserIDs: [UUID] = []) {
        self.id = id
        self.contributorName = contributorName
        self.caption = caption
        self.imageData = imageData
        self.likes = likes
        self.likedByUserIDs = likedByUserIDs
    }
}

struct CommentEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var contributorName: String
    var text: String
    var likes: Int
    var likedByUserIDs: [UUID]

    init(id: UUID = UUID(), contributorName: String, text: String, likes: Int, likedByUserIDs: [UUID] = []) {
        self.id = id
        self.contributorName = contributorName
        self.text = text
        self.likes = likes
        self.likedByUserIDs = likedByUserIDs
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
