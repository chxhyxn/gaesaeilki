//
//  FailureNoteNavigatorView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/16/25.
//

import SwiftUI
import SwiftData

struct FailureNoteNavigatorView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DogBird.createdAt, order: .reverse) private var dogBirds: [DogBird]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(dogBirds) { dogBird in
                    DogBirdCardView(dogBird: dogBird)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("실패 노트")
    }
}

struct DogBirdCardView: View {
    let dogBird: DogBird
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dogBird.name)
                    .font(.headline)
                Spacer()
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(dogBird.failureNote)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            if !dogBird.goalAtCreation.isEmpty {
                Text("목표: \(dogBird.goalAtCreation)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image("\(dogBird.type_id)")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 22, height: 22)
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: dogBird.createdAt)
    }
}
