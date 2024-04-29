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
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        
        @CasePathable
        public enum Alert: Equatable {
            // Empty Alert
        }
        
        @CasePathable
        public enum ConfirmationDialog {
            case confirmDelete
            case cancelDelete
        }
    }
    
    /// The state struct for `ExercisesList`.
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        
        /// An array of exercise row states.
        var exercises: IdentifiedArrayOf<ExerciseRow.State> = []
        
        fileprivate var exerciseToBeDeleted: ObjectIdentifier? = nil
        
        
        public init(exercises: IdentifiedArrayOf<ExerciseRow.State> = []) {
            self.exercises = exercises
        }
    }
    
    /// Actions that can be performed on `ExercisesList`.
    public enum Action {
        /// Action to handle exercises.
        case exercises(IdentifiedActionOf<ExerciseRow>)
        
        /// Deletes the workout. Use with caution as this action is irreversible.
        /// - Warning: This action is irreversible. Make sure you want to permanently delete the workout.
        @available(*, message: "Use with caution as this action is irreversible. Do not call directly Use `deleteButtonTapped` instead")
        case delete
        case deleteButtonTapped(id: ObjectIdentifier)
        
        case destination(PresentationAction<Destination.Action>)
        
        case move(IndexSet, Int)
    }
    
    /// The body of the reducer.
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .exercises:
                return .none
                
            case .delete:
                state.exerciseToBeDeleted = nil
                return .none
                
            case .deleteButtonTapped:
                state.destination = .confirmationDialog(.deleteExercise())
                return .none
                
            case let .destination(.presented(.confirmationDialog(dialog))):
                switch dialog {
                case .confirmDelete:
                    return .run { [id = state.exerciseToBeDeleted] send in
                        if let id = id {
                            await send(.exercises(.element(id: id, action: .delegate(.delete))))
                        }
                        await send(.delete)
                    }
                case .cancelDelete:
                    return .none
                }
                
            case .destination:
                return .none
                
            case let .move(source, destination):
                if let workout = state.exercises.first?.exercise.workout {
                    workout.moveExercise(fromOffsets: source, toOffset: destination)
                }
                state.exercises.move(fromOffsets: source, toOffset: destination)
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
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
    @Bindable var store: StoreOf<ExercisesList>
    /// Flag indicating whether the list is editable.
    var isEditable: Bool
    
    var body: some View {
        ForEach(store.scope(state: \.exercises, action: \.exercises)) { exercise in
            ExerciseRowView(store: exercise, isEditable: isEditable)
                .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
                .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
            // FIXME: Not working
            /*.swipeActions(edge: .trailing) {
             Button {
             store.send(.deleteButtonTapped(id: exercise.id), animation: .default)
             } label: {
             Label("Delete", systemImage: "trash")
             }
             .tint(.red)
             .disabled(isEditable.not())
             }*/
        }
        .onDelete(perform: delete)
        .onMove(perform: move)
        .deleteDisabled(isEditable.not())
        .moveDisabled(isEditable.not())
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
    
    func move(from source: IndexSet, to destination: Int) {
        store.send(.move(source, destination))
    }
}

extension AlertState where Action == ExercisesList.Destination.Alert {
    
}

extension ConfirmationDialogState where Action == ExercisesList.Destination.ConfirmationDialog {
    static func deleteExercise() -> Self {
        Self {
            TextState("Delete exercise?")
        } actions: {
            ButtonState(role: .destructive, action: .confirmDelete) {
                TextState("Yes")
            }
            ButtonState(role: .cancel, action: .cancelDelete) {
                TextState("Nevermind")
            }
        } message: {
            TextState("Are you sure you want to delete this exercise?")
        }
    }
}

#Preview {
    ExercisesListView(store: StoreOf<ExercisesList>(initialState: ExercisesList.State(), reducer: {
        ExercisesList()
    }), isEditable: true)
}
