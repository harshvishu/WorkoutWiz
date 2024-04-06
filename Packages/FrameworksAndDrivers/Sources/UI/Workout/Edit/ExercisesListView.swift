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
        /// Action to delete an exercise.
        case delete(exercise: ExerciseRow.State)
        
        /// Action to delegate an operation.
        case delegate(Delegate)
        
        /// Enum representing delegate operations.
        public enum Delegate: Equatable {
            /// Delegate operation to delete an exercise.
            case delete(exercise: ExerciseRow.State)
        }
    }
    
    /// The body of the reducer.
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .delete(exercise):
                return .send(.delegate(.delete(exercise: exercise)))
            case .exercises:
                return .none
            case .delegate:
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
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.listRowContentInset)
            }
            .onDelete(perform: delete)
    }
    
    /**
     Deletes exercises at the specified indices.
     - Parameter indexSet: The indices of exercises to delete.
     */
    func delete(at indexSet: IndexSet) {
        for index in indexSet {
            let exercise = store.exercises[index]
            store.send(.delete(exercise: exercise))
        }
    }
}

#Preview {
    ExercisesListView(store: StoreOf<ExercisesList>(initialState: ExercisesList.State(), reducer: {
        ExercisesList()
    }), isEditable: true)
}
