//
//  Pantomime_BaziApp.swift
//  Pantomime Bazi
//
//  Created by Erfan Yarahmadi on 01/04/2026.
//

import SwiftUI

@main
struct PantomimApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var appSettings = AppSettings()
    @State private var vm = GameViewModel()
    @State private var showOnboarding = false

    var body: some View {
        SetupView(vm: vm, appSettings: appSettings)
            .onAppear {
                if !appSettings.hasSeenOnboarding {
                    showOnboarding = true
                }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView {
                    appSettings.hasSeenOnboarding = true
                    showOnboarding = false
                }
            }
    }
}
