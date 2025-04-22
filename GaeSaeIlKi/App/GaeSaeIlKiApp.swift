//
//  GaeSaeIlKiApp.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/9/25.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImageWebPCoder

@main
struct GaeSaeIlKiApp: App {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @AppStorage("hasNoGoal") var hasNoGoal: Bool = true
    
    @State private var appState = AppState()

    init() {
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .onAppear() {
                    if isFirstLaunch {
                        appState.currentScreen = .onboarding
                    } else if hasNoGoal {
                        appState.currentScreen = .onboarding // TODO: 온보딩뷰 띄우기용
                        isFirstLaunch = true // TODO: 온보딩뷰 띄우기용
                    } else {
                        appState.currentScreen = .main
                    }
                }
        }
    }
}
