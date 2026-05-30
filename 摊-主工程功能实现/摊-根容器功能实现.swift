//
//  ContentView.swift
//  3180941
//
//  Created by student01 on 2026/3/29.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appModel = TanAppModel()
    @State private var showSplashOverlay = true

    var body: some View {
        NavigationStack {
            HomeView()
        }
        .environmentObject(appModel)
        .overlay {
            if showSplashOverlay {
                SplashView {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showSplashOverlay = false
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
