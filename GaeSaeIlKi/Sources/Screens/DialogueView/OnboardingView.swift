//
//  OnboardingView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/21/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("currentScreen") var currentScreen: ViewScreen = .onboarding
    
    @State private var currentDialogueIndex = 0
    @State private var isAnimating = true
    
    private let dialogues = [
        "반갑다. 나는 개새일기의 마스코트 '개새'다.",
        "너의 목표를 정하고 너의 실패를 개새일기로 남겨라.",
        "실패는 성공의 어머니라고 하지 않던가?",
        "매일 작은 실패로부터 배우며 성장하는 여정을 기록해보자.",
    ]
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                Image("GaeSae")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .offset(y: isAnimating ? 0 : 10)
                    .animation(
                        Animation.easeInOut(duration: 0.2)
                            .repeatCount(8, autoreverses: false),
                        value: isAnimating
                    )
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
        .onAppear() {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isAnimating = false
            }
        }
        .onTapGesture {
            handleTap()
        }
    }
    
    private func handleTap() {
        if currentDialogueIndex < dialogues.count - 1 {
            isAnimating = true
            withAnimation {
                currentDialogueIndex += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isAnimating = false
            }
        } else {
            currentScreen = .setGoal
        }
    }
}
