//
//  RootView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        VStack {
            switch appState.currentScreen {
            case .onboarding:
                OnboardingView()
            case .setGoal:
                SetGoalView()
            case .main:
                MainView()
                    .modelContainer(for: [DogBird.self])
            }
        }
        .preferredColorScheme(.light)
    }
}
