//
//  CloudArchiveService.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import Foundation

protocol CloudArchiveService {
    func loadSnapshot() async throws -> ArchiveSnapshot
    func saveSnapshot(_ snapshot: ArchiveSnapshot) async throws
}

struct ArchiveSnapshot: Codable {
    var user: AppUser
    var archives: [CityArchive]
    var favoriteIDs: Set<UUID>
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
