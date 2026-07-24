//
//  TanApp.swift
//  TanApp
//
//  Created by Codex on 2026/6/3.
//

import SwiftUI

@main
struct TanApp: App {
    @StateObject private var store = ArchiveStore(
        repository: LocalArchiveRepository(),
        photoStorage: LocalPhotoStorageService()
    )

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environment(\.locale, Locale(identifier: "zh_Hans_CN"))
                .preferredColorScheme(.light)
        }
    }
}
