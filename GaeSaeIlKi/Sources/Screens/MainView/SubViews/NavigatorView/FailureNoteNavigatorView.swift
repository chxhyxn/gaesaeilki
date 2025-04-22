import SwiftUI
import SwiftData

struct FailureNoteNavigatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \DogBird.createdAt, order: .reverse) private var dogBirds: [DogBird]
    
    @State private var selectedFilter: DogBirdFilter = .current
    
    private enum DogBirdFilter {
        case current
        case past
    }
    
    private var filteredDogBirds: [DogBird] {
        switch selectedFilter {
        case .current:
            return dogBirds.filter { !$0.isFlyAway }
        case .past:
            return dogBirds.filter { $0.isFlyAway }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("필터", selection: $selectedFilter) {
                    Text("현재 목표").tag(DogBirdFilter.current)
                    Text("과거 목표").tag(DogBirdFilter.past)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if filteredDogBirds.isEmpty {
                    Spacer()
                    Text(selectedFilter == .current ? "현재 목표의 개새일기가 없습니다." : "과거 목표의 개새일기가 없습니다.")
                        .font(.title2)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredDogBirds) { dogBird in
                            NavigationLink(destination: DogBirdDetailView(dogBird: dogBird)) {
                                DogBirdCardView(dogBird: dogBird)
                            }
                        }
                        .onDelete(perform: deleteFilteredItems)
                    }
                    .listStyle(.plain)
                }
            }
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
    
    private func deleteFilteredItems(at offsets: IndexSet) {
        // Convert offsets from filteredDogBirds to the actual dogBirds array
        let filteredItemsToDelete = offsets.map { filteredDogBirds[$0] }
        
        for dogBird in filteredItemsToDelete {
            modelContext.delete(dogBird)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting items: \(error.localizedDescription)")
        }
    }
}
