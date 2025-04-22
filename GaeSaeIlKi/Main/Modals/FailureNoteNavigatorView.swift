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
