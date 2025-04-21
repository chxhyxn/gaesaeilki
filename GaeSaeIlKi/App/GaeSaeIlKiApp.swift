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
    @State private var viewModel = ContentViewModel()

    init() {
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
