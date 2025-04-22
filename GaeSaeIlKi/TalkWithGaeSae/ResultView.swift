//
//  ResultView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/22/25.
//

import SwiftUI
import SwiftData

struct ResultView: View {
    @AppStorage("currentScreen") var currentScreen: ViewScreen = .onboarding
    @AppStorage("currentGoal") var currentGoal: String = ""
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<DogBird> { !$0.isFlyAway }) private var dogBirds: [DogBird]

    @State private var currentDialogueIndex = 0
    @State private var isAnimating = true
    
    private let dialogues = [
        "오랜만이야.",
        "너의 실패들은 잘 봤다.",
        "특히 ~는 인상적이군.",
        "그래서 목표했던 일은 이뤘나? 아직 아니라고? 괜찮아.",
        "실패에서 배우는 교훈이 때로는 성공보다 값지다는 걸 넌 이미 알고 있을 거야.",
        "이번 실패에서 얻은 교훈은 다음 도전의 밑거름이 될 것이다.",
        "이제 다음 목표를 향해 나아갈 준비가 됐나?"
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
            currentGoal = ""
            // dogBird들의 isFlyaway 속성을 모두 true로 변환
            for dogBird in dogBirds {
                dogBird.isFlyAway = true
                try? modelContext.save()
            }
            currentScreen = .setGoal
        }
    }
}
