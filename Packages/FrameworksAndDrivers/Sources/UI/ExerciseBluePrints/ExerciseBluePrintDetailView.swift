//
//  ExerciseBluePrintDetailView.swift
//
//
//  Created by harsh vishwakarma on 05/04/24.
//

import SwiftUI
import Domain
import ComposableArchitecture
import DesignSystem

@Reducer
public struct ExerciseBluePrintDetails {
    @ObservableState
    public struct State: Equatable {
        var exercise: ExerciseBluePrint
    }
    
    public enum Action: Equatable {
        
    }
}

struct ExerciseDetailView: View {
    let store: StoreOf<ExerciseBluePrintDetails>
    
    var body: some View {
        Form {
//            Text(store.exercise.name)
//                .font(.title)
//                .bold()
            
            if let force = store.exercise.force?.rawValue {
                
                LabeledContent("Force", value: force.capitalized)
            }
            LabeledContent("Level", value: store.exercise.level.rawValue.capitalized)
            
            if let mechanic = store.exercise.mechanic?.rawValue {
                LabeledContent("Mechanic", value: mechanic.capitalized)
            }
            if let equipment = store.exercise.equipment?.rawValue {
                LabeledContent("Equipment", value: equipment.capitalized)
            }
            Section("Category") {
                Label(store.exercise.category.rawValue.capitalized, systemImage: store.exercise.category.iconForCategory())
            }
            
            if store.exercise.primaryMuscles.isNotEmpty {
                Section("Primary Muscles") {
                    ForEach(store.exercise.primaryMuscles, id: \.self) { muscle in
                        Text(muscle.rawValue.capitalized)
                    }
                }
            }
            if store.exercise.secondaryMuscles.isNotEmpty {
                Section("Secondary Muscles") {
                    ForEach(store.exercise.secondaryMuscles, id: \.self) { muscle in
                        Text(muscle.rawValue.capitalized)
                    }
                }
            }
            
            if store.exercise.instructions.isNotEmpty {
                Section("Instructions") {
                    ForEachWithIndex(store.exercise.instructions, id: \.self) { idx, instruction in
                        Label(instruction, systemImage: "\(idx + 1).circle.fill")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(store.exercise.name)
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(store: StoreOf<ExerciseBluePrintDetails>(initialState: ExerciseBluePrintDetails.State(exercise: ExerciseBluePrint(ExerciseTemplate.mock_1)), reducer: {
            ExerciseBluePrintDetails()
        }))
    }
}
