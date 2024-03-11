//
//  WorkoutRowView.swift
//
//
//  Created by harsh vishwakarma on 29/12/23.
//

import SwiftUI
import Domain
import DesignSystem

struct WorkoutRowView: View {
    var workout: Workout
    
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
                    //                        .foregroundStyle(.secondary)
                        .previewBorder(.red.opacity(0.2))
                }
                .previewBorder(.green.opacity(0.2))
                
                Spacer()
                
                
                // MARK: Tags
                if workout.abbreviatedMuscle != .none {
                    Text(workout.abbreviatedMuscle.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .previewBorder(.red.opacity(0.2))
                }
                
            }
            .previewBorder(.blue.opacity(0.2))
            
            HStack {
                
                Spacer()
                
                // TODO: Use tags & a dropdown
            }
            .previewBorder(.purple.opacity(0.5))
            
            Divider()
            
            HStack(spacing: 0) {
                let energy =  Measurement(value: workout.calories, unit: UnitEnergy.kilocalories)
                Label(energy.formatted(.measurement(width: .abbreviated, usage: .workout)), systemImage: "flame")
                    .frame(maxWidth: .infinity)
                    .previewBorder(.red.opacity(0.2))
                
                Circle()
                    .fill()
                    .frame(width: 4)
                    .previewBorder(.red.opacity(0.2))
                
                // TODO: Fix Time Duration
                
                Label(formatTime(workout.duration), systemImage: "timer")
                    .frame(maxWidth: .infinity)
                    .previewBorder(.red.opacity(0.2))
                
                // TODO: Fix
                if workout.abbreviatedCategory != .none {
                    Circle()
                        .fill()
                        .frame(width: 4)
                        .previewBorder(.red.opacity(0.2))
                    
                    Label(workout.abbreviatedCategory.rawValue, systemImage: Workout.iconFor(category: workout.abbreviatedCategory))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: .infinity)
                        .previewBorder(.red.opacity(0.2))
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity)
                        .previewBackground(.red.opacity(0.2))
                }
                
            }
            .font(.caption2)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .previewBorder(Color.red.opacity(0.2))
            
        }
        .padding(.listRowContentInset)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .stroke(.tertiary, lineWidth: 0.5)
                .shadow(color: .secondary.opacity(0.1), radius: 0, x: 0.0, y: 2.0)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .id(workout.id)
    }
}

//#Preview {
//    WorkoutRowView(workout: .mock)
//}
