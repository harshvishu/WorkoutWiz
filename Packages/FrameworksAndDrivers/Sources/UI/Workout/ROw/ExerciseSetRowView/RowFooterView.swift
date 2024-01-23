//
//  RowFooterView.swift
//  
//
//  Created by harsh vishwakarma on 20/01/24.
//

import Domain
import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import OSLog

// Footer View
struct RowFooterView: View {
    @Environment(SaveDataManager.self) private var saveDataManager
    
    var editWorkoutViewModel: WorkoutEditorViewModel
    
    @Binding var exercise: ExerciseRecord
    @State var lastSavedSet: ExerciseSet = .init(exerciseID: UUID(), weight: 0, type: .rep, duration: 0.0, rep: 0, calories: 0.0)
    
    var body: some View {
            Button(action: {
                if let addedSet = editWorkoutViewModel.addSetToExercise(withID: exercise.id, weight: lastSavedSet.weight, type: lastSavedSet.type, duration: lastSavedSet.duration, rep: lastSavedSet.rep, unit: lastSavedSet.unit, failure: lastSavedSet.failure) {
                    withCustomSpring {
                        exercise.sets.append(addedSet)
                    }
                }
                
            }, label: {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    if exercise.sets.isEmpty  {
                        Label("No sets for this exercise.", systemImage: "lightbulb.circle.fill")
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                    } else {
                        let energy =  Measurement(value: exercise.estimatedCaloriesBurned(), unit: UnitEnergy.kilocalories)
                        Label(energy.formatted(.measurement(width: .abbreviated, usage: .workout)), systemImage: "flame")
                            .foregroundStyle(.purple)
                    }
                    
                    Spacer()
                    
                    Text("Add a set")
                        .foregroundStyle(.purple)
                        .fontWeight(.semibold)
                        .padding(2)
                }
                .font(.footnote)
                
            })
            .buttonStyle(.plain)
            .padding(EdgeInsets(top: 20, leading: 4, bottom: 2, trailing: 4))
            .background(
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 0.0,
                    bottomLeading: 8.0,
                    bottomTrailing: 8.0,
                    topTrailing: 0.0), style: .continuous)
                .fill(Color.purple.opacity(0.2))
            )
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            .offset(y: -16)
            .task {
                //            await lastSavedSet = saveDataManager.readSaveDataFor(exerciseName: exercise.template.name)?.sets.first ?? .init(weight: 5.0, rep: 10)
            }

    }
}
