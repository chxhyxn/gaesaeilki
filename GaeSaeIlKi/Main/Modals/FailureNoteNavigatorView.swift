import SwiftUI
import SwiftData

struct FailureNoteNavigatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \DogBird.createdAt, order: .reverse) private var dogBirds: [DogBird]
    
    var body: some View {
        NavigationStack {
            if dogBirds.isEmpty {
                Text("아직 개새일기가 없습니다.")
                    .font(.title2)
            } else {
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
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(dogBirds[index])
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting items: \(error.localizedDescription)")
        }
    }
}
