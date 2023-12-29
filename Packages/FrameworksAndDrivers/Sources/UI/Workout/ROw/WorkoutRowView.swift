//
//  WorkoutRowView.swift
//
//
//  Created by harsh vishwakarma on 29/12/23.
//

import SwiftUI
import Domain

struct WorkoutRowView: View {
    var workout: WorkoutRecord
    
    var body: some View {
        VStack {
            HStack {
                Text(workout.name ?? "Workout")
                Spacer()
                
                Image(systemName: "ellipsis.rectangle")
            }
            
            HStack {
                Text("Monday, 4 Dec")
                
                Spacer()
                
                // TODO: Use tags & a dropdown
                Label("Pull", systemImage: "dumbbell")
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(in: .capsule)
                    .backgroundStyle(.tertiary)
                    .clipShape(.capsule)
            }
        }
        .padding(.listRowContentInset)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.tertiary, lineWidth: 0.5)
                .onTapGesture {
                    // TODO: Open detailed view for editing
                }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
//        .listRowInsets(.listRowInset)
    }
}

#Preview {
    WorkoutRowView(workout: .mock(0))
        .previewBorder()
}
