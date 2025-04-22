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
    init() {
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(for: [DogBird.self])
        }
    }
}
