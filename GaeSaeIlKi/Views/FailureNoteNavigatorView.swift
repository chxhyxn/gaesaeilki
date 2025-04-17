import SwiftUI
import SwiftData

struct FailureNoteNavigatorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \DogBird.createdAt, order: .reverse) private var dogBirds: [DogBird]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dogBirds) { dogBird in
                    NavigationLink(destination: DogBirdDetailView(dogBird: dogBird)) {
                        DogBirdCardView(dogBird: dogBird)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(.plain)
            .navigationTitle("개새일기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            context.delete(dogBirds[index])
        }
        
        do {
            try context.save()
        } catch {
            print("Error deleting items: \(error.localizedDescription)")
        }
    }
}

struct DogBirdCardView: View {
    let dogBird: DogBird
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image("\(dogBird.type_id)")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading) {
                    if !dogBird.goalAtCreation.isEmpty {
                        Text("목표: \(dogBird.goalAtCreation)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }else {
                        Text("목표: 당시 목표 없음")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.8))
                            .lineLimit(1)
                    }
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            Text(dogBird.failureNote)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical)
        .buttonStyle(PlainButtonStyle())
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: dogBird.createdAt)
    }
}

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
