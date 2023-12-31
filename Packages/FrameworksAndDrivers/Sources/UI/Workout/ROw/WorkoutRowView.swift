//
//  WorkoutRowView.swift
//
//
//  Created by harsh vishwakarma on 29/12/23.
//

import SwiftUI
import Domain

struct WorkoutRowView: View {
    @Environment(RouterPath.self) var routerPath
    
    var workout: WorkoutRecord
    
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    
                    // MARK: Workout Name
                    Text("\(workout.name.isEmpty ? "Workout" : workout.name)")
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    
                    Text(workout.startDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .previewBorder(.red.opacity(0.2))
                }
                .previewBorder(.green.opacity(0.2))
                
                Spacer()
                
                
                // MARK: Tags
                Text("\(workout.exercises.first?.template.primaryMuscles?.first ?? "")")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .previewBorder(.red.opacity(0.2))
            }
            .previewBorder(.blue.opacity(0.2))
            
            HStack {
                
                Spacer()
                
                // TODO: Use tags & a dropdown
            }
            
            Divider()
            
            // TODO: Add adaptive class
            HStack {
                Label("\(workout.estimatedCaloriesBurned(), specifier: "%d") Kcal", systemImage: "flame")
                    .frame(maxWidth: .infinity)
                
                Circle()
                    .fill()
                    .frame(width: 4)
                
                // TODO: Fix Time Duration
                Label("45 Min", systemImage: "timer")
                    .frame(maxWidth: .infinity)
                
                Circle()
                    .fill()
                    .frame(width: 4)
                
                Label("\(workout.abbreviatedCategory())", systemImage: "dumbbell")
                    .frame(maxWidth: .infinity)
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
            
        }
        .padding(.listRowContentInset)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.windowBackground)
                .stroke(.tertiary, lineWidth: 0.5)
                .shadow(color: .secondary.opacity(0.1), radius: 20, x: 0.0, y: 2.0)
                .onTapGesture {
                    routerPath.navigate(to: .workoutDetails(workout: workout))
                }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .id(workout.id)
    }
}

#Preview {
    WorkoutRowView(workout: .mock(0))
}
