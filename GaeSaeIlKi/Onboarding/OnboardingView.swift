//
//  OnboardingView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/21/25.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) var appState
    
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    @State private var currentDialogueIndex = 0
    @State private var showGoalView = false
    
    private let dialogues = [
        "반갑다. 나는 개새일기의 마스코트 '개새'다.",
        "너의 목표를 정하고 너의 실패를 개새일기로 남겨라.",
        "실패는 성공의 어머니라고 하지 않던가?",
        "매일 작은 실패로부터 배우며 성장하는 여정을 기록해보자.",
        "자, 이제 목표를 설정해보자."
    ]
    
    var body: some View {
        ZStack {
            Color(.white)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    Image("GaeSae")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                .padding(.horizontal, 30)
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(radius: 5)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("개새")
                            .font(.title.bold())
                            .padding(.bottom, 5)
                        
                        Text(dialogues[currentDialogueIndex])
                            .font(.body)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            Text("터치하여 계속")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .opacity(0.8)
                        }
                    }
                    .padding(24)
                }
                .frame(maxHeight: 220)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .onTapGesture {
            handleTap()
        }
    }
    
    // Function to handle user taps
    private func handleTap() {
        // If not at the last dialogue, move to next
        if currentDialogueIndex < dialogues.count - 1 {
            currentDialogueIndex += 1
        } else {
            appState.currentScreen = .setGoal
            isFirstLaunch = false
        }
    }
}
