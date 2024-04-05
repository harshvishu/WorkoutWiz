//
//  ExerciseBluePrintDetailView.swift
//  
//
//  Created by harsh vishwakarma on 05/04/24.
//

import SwiftUI
import Domain
import ComposableArchitecture

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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(store.exercise.name)
                    .font(.title)
                    .bold()
                
                if let force = store.exercise.force?.rawValue {
                    Text("Force: \(force.capitalized)")
                }
                Text("Level: \(store.exercise.level.rawValue.capitalized)")
                if let mechanic = store.exercise.mechanic?.rawValue {
                    Text("Mechanic: \(mechanic.capitalized)")
                }
                if let equipment = store.exercise.equipment?.rawValue {
                    Text("Equipment: \(equipment.capitalized)")
                }
                
                Text("Category: \(store.exercise.category.rawValue.capitalized)")
                
                if store.exercise.primaryMuscles.isNotEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Primary Muscles:")
                            .font(.headline)
                        ForEach(store.exercise.primaryMuscles, id: \.self) { muscle in
                            Text("- \(muscle)")
                        }
                    }
                }
                if store.exercise.secondaryMuscles.isNotEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Secondary Muscles:")
                            .font(.headline)
                        ForEach(store.exercise.secondaryMuscles, id: \.self) { muscle in
                            Text("- \(muscle)")
                        }
                    }
                }
                
                if store.exercise.instructions.isNotEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions:")
                            .font(.headline)
                        ForEach(store.exercise.instructions, id: \.self) { instruction in
                            Text("- \(instruction)")
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(store: StoreOf<ExerciseBluePrintDetails>(initialState: ExerciseBluePrintDetails.State(exercise: ExerciseBluePrint(ExerciseTemplate.mock_1)), reducer: {
            ExerciseBluePrintDetails()
        }))
    }
}
