//
//  TanApp.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI

@main
struct TanApp: App {
    @StateObject private var store = ArchiveStore(cloudService: MockCloudArchiveService())

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
