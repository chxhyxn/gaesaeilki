//
//  SetGoal.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/21/25.
//

import SwiftUI

struct SetGoalView: View {
    @Environment(AppState.self) var appState
    
    @AppStorage("currentGoal") var currentGoal: String = ""
    @AppStorage("hasNoGoal") var hasNoGoal: Bool = true

    @State private var currentDialogueIndex = 0
    @State private var showConfirmationAlert = false
    
    @FocusState private var isTextFieldFocused: Bool
    
    private let dialogues = [
        "자, 이제 목표를 설정해보자.",
        "자, 이제 목표를 설정해보자.",
        "라.. 멋진 목표군.",
        "이제 이 목표를 향해 달려가자.",
        "우린 20번의 실패 후에 다시 만날 거야.",
        "더 성장한 모습의 너가 기대되는 군..."
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
                        
                        Text((currentDialogueIndex == 2 ? "\"\(currentGoal)\"" : "") + dialogues[currentDialogueIndex])
                            .font(.body)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                        
                        if currentDialogueIndex == 1 {
                            TextField("✏️ 당신의 목표를 작성하세요.", text: $currentGoal)
                                .multilineTextAlignment(.center)
                                .fontWeight(.black)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(isTextFieldFocused ? .white : .white.opacity(0.5))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .focused($isTextFieldFocused)
                        }
                        
                        Spacer()
                        
                        if currentDialogueIndex == 1 {
                            HStack {
                                Spacer()
                                Button(action: {
                                    if !currentGoal.isEmpty {
                                        showConfirmationAlert = true
                                    }
                                }) {
                                    Text("작성 완료")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(currentGoal.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                                        )
                                        .opacity(currentGoal.isEmpty ? 0.6 : 1.0)
                                }
                                .disabled(currentGoal.isEmpty)
                            }
                        } else {
                            HStack {
                                Spacer()
                                Text("터치하여 계속")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .opacity(0.8)
                            }
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
            if currentDialogueIndex != 1 {
                handleTap()
            }
        }
        .alert("목표 설정", isPresented: $showConfirmationAlert) {
            Button("취소", role: .cancel) {}
            Button("설정") {
                handleTap()
            }
        } message: {
            Text("'\(currentGoal)'을(를) 목표로 설정하시겠습니까?\n설정된 목표는 20번의 실패일기 작성 후 재설정할 수 있습니다.")
        }
    }
    
    // Function to handle user taps
    private func handleTap() {
        // If not at the last dialogue, move to next
        if currentDialogueIndex < dialogues.count - 1 {
            currentDialogueIndex += 1
        } else {
            appState.currentScreen = .main
            hasNoGoal = false
        }
    }
}
