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
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                Text(dogBird.failureNote)
                    .font(.body)
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("개새일기 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: dogBird.createdAt)
    }
}
