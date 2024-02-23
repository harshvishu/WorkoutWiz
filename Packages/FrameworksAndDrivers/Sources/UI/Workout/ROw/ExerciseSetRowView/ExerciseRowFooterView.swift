//
//  ExerciseRowFooterView.swift
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
struct ExerciseRowFooterView: View {
    @Environment(SaveDataManager.self) private var saveDataManager
    @Environment(AppState.self) var appState
    
    var exercise: Exercise
    @State var lastSavedSet: Rep = .init(weight: 0.0, countUnit: .rep, time: 0.0, count: 10, weightUnit: .kg, calories: 0.0, position: 0, repType: .none)
    
    var body: some View {
            Button(action: {
                appState.send(.popup(.addSetToExercise(exercise)))
            }, label: {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    if exercise.reps.isEmpty  {
                        Label("No sets for this exercise.", systemImage: "lightbulb.circle.fill")
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                    } else {
                        let energy =  Measurement(value: exercise.calories, unit: UnitEnergy.kilocalories)
                        Label(energy.formatted(.measurement(width: .abbreviated, usage: .workout)), systemImage: "flame")
                            .foregroundStyle(.primary)
                        
                        if let maxWeightLifted = exercise.maxWeightLifted , !maxWeightLifted.isZero {
                            let weight = Measurement(value: maxWeightLifted, unit: UnitMass.kilograms)
                            Label(weight.formatted(.measurement(width: .narrow, usage: .general)), systemImage: "scalemass.fill")
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    Text("Add a set")
                        .foregroundStyle(.primary)
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
                .fill(Color.black.opacity(0.2))
            )
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            .offset(y: -16)
    }
}
