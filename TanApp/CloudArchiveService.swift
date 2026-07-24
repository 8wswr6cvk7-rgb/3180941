//
//  CloudArchiveService.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import Foundation

protocol ArchiveRepository {
    func loadSnapshot() async throws -> ArchiveSnapshot
    func saveSnapshot(_ snapshot: ArchiveSnapshot) async throws
}

protocol CloudArchiveService {
    func loadSnapshot() async throws -> ArchiveSnapshot
    func saveSnapshot(_ snapshot: ArchiveSnapshot) async throws
}

struct ArchiveSnapshot: Codable {
    var user: AppUser
    var archives: [CityArchive]
    var favoriteIDs: Set<UUID>
    var visitedArchiveIDs: Set<UUID> = []
    var litArchiveIDs: Set<UUID> = []
}

actor LocalArchiveRepository: ArchiveRepository {
    private let fileURL: URL

    init(rootURL: URL? = nil) {
        if let rootURL {
            fileURL = rootURL.appendingPathComponent("archive_snapshot.json")
        } else {
            let directory = (try? FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ))?.appendingPathComponent("TanUrbanEcho", isDirectory: true)
                ?? FileManager.default.temporaryDirectory.appendingPathComponent("TanUrbanEcho", isDirectory: true)
            fileURL = directory.appendingPathComponent("archive_snapshot.json")
        }
    }

    func loadSnapshot() async throws -> ArchiveSnapshot {
        let manager = FileManager.default
        guard manager.fileExists(atPath: fileURL.path) else {
            let seed = ArchiveSnapshot(
                user: MockArchiveData.currentUser,
                archives: MockArchiveData.competitionSeedArchives,
                favoriteIDs: Set(MockArchiveData.competitionSeedArchives.prefix(3).map(\.id))
            )
            try await saveSnapshot(seed)
            return seed
        }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder.archiveDecoder.decode(ArchiveSnapshot.self, from: data)
    }

    func saveSnapshot(_ snapshot: ArchiveSnapshot) async throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let data = try JSONEncoder.archiveEncoder.encode(snapshot)
        try data.write(to: fileURL, options: .atomic)
    }
}

private extension JSONEncoder {
    static var archiveEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var archiveDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

actor MockCloudArchiveService: CloudArchiveService {
    private var snapshot = ArchiveSnapshot(
        user: MockArchiveData.currentUser,
        archives: MockArchiveData.archives,
        favoriteIDs: Set(MockArchiveData.archives.prefix(3).map(\.id))
    )

    func loadSnapshot() async throws -> ArchiveSnapshot {
        try await Task.sleep(for: .milliseconds(250))
        return snapshot
    }

    func saveSnapshot(_ snapshot: ArchiveSnapshot) async throws {
        try await Task.sleep(for: .milliseconds(180))
        self.snapshot = snapshot
    }
}

struct CloudKitArchiveService: CloudArchiveService {
    func loadSnapshot() async throws -> ArchiveSnapshot {
        // Swap this mock bridge for CloudKit records when a real iCloud container is available.
        ArchiveSnapshot(user: MockArchiveData.currentUser, archives: MockArchiveData.archives, favoriteIDs: [])
    }

    func saveSnapshot(_ snapshot: ArchiveSnapshot) async throws {
        _ = snapshot
    }
}
