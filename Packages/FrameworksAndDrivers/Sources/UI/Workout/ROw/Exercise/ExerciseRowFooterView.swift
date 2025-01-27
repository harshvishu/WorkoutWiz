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
import ComposableArchitecture

// Footer View
struct ExerciseRowFooterView: View {
    
    let store: StoreOf<ExerciseRow>
    var isEditable: Bool
    
    @State var lastSavedSet: Rep = .init(weight: 0.0, countUnit: .rep, time: 0.0, count: 10, weightUnit: .kg, calories: 0.0, repType: .standard)

    var body: some View {
            Button(action: {
                store.send(.delegate(.addNewSet), animation: .default)
            }, label: {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    if store.exercise.reps.isEmpty  {
                        Label("No sets for this exercise.", systemImage: "lightbulb.circle.fill")
                            .foregroundStyle(isEditable.not() ? Color.secondary : .accentColor)
//                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                    } else {
                        let energy =  Measurement(value: store.exercise.calories, unit: UnitEnergy.kilocalories)
                        Label(energy.formatted(.measurement(width: .abbreviated, usage: .workout)), systemImage: "flame")
                            .foregroundStyle(isEditable.not() ? Color.secondary : .accentColor)
//                            .foregroundStyle(.primary)
                        
                        if let maxWeightLifted = store.exercise.maxWeightLifted , !maxWeightLifted.isZero {
                            let weight = Measurement(value: maxWeightLifted, unit: UnitMass.kilograms)
                            Label(weight.formatted(.measurement(width: .narrow, usage: .general)), systemImage: "scalemass.fill")
                                .foregroundStyle(isEditable.not() ? Color.secondary : .accentColor)
//                                .foregroundStyle(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    Text("Add a set")
                        .foregroundStyle(isEditable.not() ? Color.secondary : .accentColor)
//                        .foregroundStyle(.primary)
                        .fontWeight(.semibold)
                        .padding(2)
                        .opacity(isEditable ? 1 : 0)
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
//                .fill(Color.black.opacity(0.2))
                    .fill((isEditable.not() ? Color.secondary : Color.accentColor).opacity(0.2))
            )
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            .offset(y: -16)
            .disabled(isEditable.not())
    }
}
