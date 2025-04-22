import SwiftUI
import Observation

@Observable
class AppState {
    var currentScreen: ViewScreen = .onboarding
    
    enum ViewScreen {
        case onboarding
        case setGoal
        case main
    }
}
