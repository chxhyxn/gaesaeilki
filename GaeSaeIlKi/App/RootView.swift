//
//  RootView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("currentScreen") var currentScreen: ViewScreen = .onboarding

    var body: some View {
        VStack {
            switch currentScreen {
            case .onboarding:
                OnboardingView()
            case .setGoal:
                SetGoalView()
            case .showResult:
                ResultView()
            case .main:
                MainView()
            }
        }
        .preferredColorScheme(.light)
    }
}
