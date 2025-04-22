//
//  DogBirdCardView.swift
//  GaeSaeIlKi
//
//  Created by Sean Cho on 4/21/25.
//

import SwiftUI

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
