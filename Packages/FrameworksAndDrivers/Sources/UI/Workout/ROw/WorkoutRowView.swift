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
                    //                        .foregroundStyle(.secondary)
                        .previewBorder(.red.opacity(0.2))
                }
                .previewBorder(.green.opacity(0.2))
                
                Spacer()
                
                
                // MARK: Tags
                if let primaryMuscle = workout.abbreviatedMuscle() {
                    Text(primaryMuscle.rawValue)
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
                let energy =  Measurement(value: workout.estimatedCaloriesBurned(), unit: UnitEnergy.kilocalories)
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
                
                if let abbreviatedCategory = workout.abbreviatedCategory() {
                    Circle()
                        .fill()
                        .frame(width: 4)
                        .previewBorder(.red.opacity(0.2))
                    
                    Label(abbreviatedCategory.rawValue, systemImage: workout.iconForCategory())
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
    @State var routerPath: RouterPath = .init()
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return WorkoutRowView(workout: .mock(0))
        .environment(routerPath)
        .environment(globalMessageQueue)
}
