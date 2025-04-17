//
//  PopupNoteDetailView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/10/25.
//

import SwiftUI

struct PopupNoteDetailView: View {
    @Binding var isPresented: Bool
    @Binding var failureNote: String
    @State private var editedNote: String
    @State private var isEditing: Bool = false
    
    // 추가 - 당시 목표 및 생성 일자 표시를 위한 속성
    var goalAtCreation: String
    var createdAt: Date
        
    @GestureState private var dragOffset: CGFloat = 0
    
    init(isPresented: Binding<Bool>, failureNote: Binding<String>, goalAtCreation: String = "", createdAt: Date = Date()) {
        self._isPresented = isPresented
        self._failureNote = failureNote
        self._editedNote = State(initialValue: failureNote.wrappedValue)
        self.goalAtCreation = goalAtCreation
        self.createdAt = createdAt
    }
    
    var body: some View {
        ZStack {
            // Glassmorphism popup card
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack() {
                    Text("실패 일기")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // 손잡이
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 40, height: 5)
                        .padding(.bottom, 16)
                    
                    Spacer()
                    
                    if isEditing {
                        Button(action: {
                            commitChanges()
                        }) {
                            Text("저장")
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.primary)
                        }
                    } else {
                        Button(action: {
                            isEditing = true
                        }) {
                            Text("수정")
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Divider()
                    .background(Color.white.opacity(0.7))
                
                // 당시 목표 표시 (비어있지 않을 경우에만)
                if !goalAtCreation.isEmpty {
                    Text("당시 목표 : \(goalAtCreation)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                } else {
                    Text("당시 목표 : 설정된 목표 없음")
                        .font(.subheadline)
                        .foregroundColor(.primary.opacity(0.7))
                        .padding(.horizontal)
                }
                
                // 날짜 포맷터
                Text("생성 일자 : \(formattedDate(createdAt))")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                // Content
                if isEditing {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThickMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        
                        TextEditor(text: $editedNote)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 11)
                            .scrollContentBackground(.hidden) // iOS 16+ 옵션
                            .background(Color.clear)
                    }
                    .frame(minHeight: 100, maxHeight: 200)
                    .padding(.horizontal)
                    .padding(.bottom)
                } else {
                    VStack {
                        Text(failureNote)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.1))
                    )
                    .frame(maxHeight: 200)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 5)
            .padding()
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.translation.height > 0 {
                            state = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 100 {
                            closePopup()
                        }
                    }
            )
        }
        .animation(.default, value: isEditing)
    }
    
    // 날짜 포맷 함수
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    private func commitChanges() {
        failureNote = editedNote
        isEditing = false
    }
    
    private func closePopup() {
        isPresented = false
    }
}
