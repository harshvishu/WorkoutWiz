//
//  WorkoutEditorExerciseListView.swift
//
//
//  Created by harsh vishwakarma on 25/12/23.
//

import Domain
import SwiftUI
import DesignSystem
import Persistence
import ApplicationServices
import SwiftData
import ComposableArchitecture

/**
 A reducer struct `ExercisesList` for managing the list of exercises.
 */
@Reducer
public struct ExercisesList {
    /// The state struct for `ExercisesList`.
    @ObservableState
    public struct State: Equatable {
        /// An array of exercise row states.
        var exercises: IdentifiedArrayOf<ExerciseRow.State> = []
    }
    
    /// Actions that can be performed on `ExercisesList`.
    public enum Action {
        /// Action to handle exercises.
        case exercises(IdentifiedActionOf<ExerciseRow>)
    }
    
    /// The body of the reducer.
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .exercises:
                return .none
            }
        }
        .forEach(\.exercises, action: \.exercises) {
            ExerciseRow()
        }
    }
}

/**
 A view struct `ExercisesListView` for displaying the list of exercises.
 */
struct ExercisesListView: View {
    /// The store of `ExercisesList`.
    let store: StoreOf<ExercisesList>
    /// Flag indicating whether the list is editable.
    var isEditable: Bool
    
    var body: some View {
        ForEach(store.scope(state: \.exercises, action: \.exercises)) {
            ExerciseRowView(store: $0, isEditable: isEditable)
        }
        .onDelete(perform: delete)
        .deleteDisabled(isEditable.not())
    }
    
    /**
     Deletes exercises at the specified indices.
     - Parameter indexSet: The indices of exercises to delete.
     */
    func delete(at indexSet: IndexSet) {
        for index in indexSet {
            let exercise = store.exercises[index]
            store.send(.exercises(.element(id: exercise.id, action: .delegate(.delete))))
        }
    }
}

#Preview {
    ExercisesListView(store: StoreOf<ExercisesList>(initialState: ExercisesList.State(), reducer: {
        ExercisesList()
    }), isEditable: true)
}
