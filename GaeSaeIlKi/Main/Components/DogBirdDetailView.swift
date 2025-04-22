//
//  DogBirdDetailView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/21/25.
//

import SwiftUI

struct DogBirdDetailView: View {
    let dogBird: DogBird
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var isEditing = false
    @State private var editedNote = ""
    @State private var showingDeleteAlert = false
    
    @FocusState private var textFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image("\(dogBird.type_id)")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading) {
                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if !dogBird.goalAtCreation.isEmpty {
                            Text("목표: \(dogBird.goalAtCreation)")
                                .font(.headline)
                        }else {
                            Text("목표: 당시 목표 없음")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                if isEditing {
                    TextField("오늘의 실패일기를 작성하세요.", text: $editedNote, axis: .vertical)
                        .font(.body)
                        .padding()
                        .focused($textFieldFocused)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(UIColor.systemGray6))
                        )
                        .padding(.horizontal)
                } else {
                    Text(dogBird.failureNote)
                        .font(.body)
                        .padding()
                        .multilineTextAlignment(.leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.white)
                        )
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("개새일기 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("저장") {
                        saveChanges()
                    }
                } else {
                    Menu {
                        Button(action: {
                            prepareForEditing()
                        }) {
                            Label("수정", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Label("삭제", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .alert("삭제하시겠습니까?", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("이 항목을 삭제하면 복구할 수 없습니다.")
        }
    }
    
    private func prepareForEditing() {
        editedNote = dogBird.failureNote
        isEditing = true
        textFieldFocused = true
    }
    
    private func saveChanges() {
        dogBird.failureNote = editedNote
        
        do {
            try context.save()
            isEditing = false
            textFieldFocused = false
        } catch {
            print("Error saving changes: \(error.localizedDescription)")
        }
    }
    
    private func deleteItem() {
        context.delete(dogBird)
        
        do {
            try context.save()
            dismiss()
        } catch {
            print("Error deleting item: \(error.localizedDescription)")
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: dogBird.createdAt)
    }
}
