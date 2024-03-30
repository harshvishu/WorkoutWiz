//
//  WorkoutEditorFeature.swift
//  
//
//  Created by harsh vishwakarma on 08/03/24.
//

import Domain
import SwiftUI
import ComposableArchitecture
import OSLog

@Reducer
public struct WorkoutEditorFeature {
    
    @Reducer(state: .equatable)
    public enum Path {
        case exerciseLists(ExerciseBluePrintsList)
        case exerciseDetails
    }
    
    @ObservableState
    public struct State: Equatable {
        var workout: Workout
        var isWorkoutSaved: Bool        // To tell if workout is persisted in database
        var isWorkoutInProgress: Bool   // To tell if workout is currently active
        var sessionStartDate: Date
        
        var path = StackState<Path.State>()
        var exercisesList: ExercisesList.State
        
        init() {
            @Dependency(\.workoutDatabase.fetchAll) var fetchAll
            _ = try? fetchAll()
            self.workout = Workout()
            self.isWorkoutSaved = false
            self.isWorkoutInProgress = false
            self.exercisesList = .init()
            self.sessionStartDate = .init()
        }
        
        init(isWorkoutSaved: Bool, isWorkoutInProgress: Bool, workout: Workout) {
            self.workout = workout
            self.isWorkoutSaved = isWorkoutSaved
            self.isWorkoutInProgress = isWorkoutInProgress
            let exercises = IdentifiedArray(
                uniqueElements: workout.exercises
                    .map({ExerciseRow.State(exercise: $0)})
                    .sorted(using: KeyPathComparator(\.exercise.sortOrder, order: .forward))    // use forward for decending order
            )
            self.exercisesList = ExercisesList.State(exercises: exercises)
            self.sessionStartDate = .init()
        }
        
        mutating func saveChanges() {
            @Dependency(\.workoutDatabase) var database
            
            if isWorkoutSaved.not() {
                do {
                    try database.add(workout)
                    isWorkoutSaved = true
                    isWorkoutInProgress = true
                } catch {
                    Logger.action.error("\(error)")
                }
            }
        }
    }
    
    public enum Action {
        case cancelButtonTapped
        case addSelectedBluePrints(bluePrints: [ExerciseBluePrint])
        case exercisesList(ExercisesList.Action)
        case finishButtonTapped
        case nameChanged(String)
        case path(StackAction<Path.State, Path.Action>)
        case reset
        case saveChanges
        case showExerciseListButtonTapped
        
        case delegate(Delegate)
        public enum Delegate {
            case collapse
            case expand
            case workoutSaved
            case activeWorkoutChanged(Workout)
            case isBottomSheetCollapsible(Bool)
            case toggleBottomSheet
        }
    }
    
    @Dependency(\.date.now) var now
    @Dependency(\.workoutDatabase) var database
    
    public var body: some ReducerOf<Self> {
        
        Scope(state: \.exercisesList, action: \.exercisesList) {
            ExercisesList()
        }
        
        Reduce<State, Action> {
            state,
            action in
            switch action {
                
            case let .addSelectedBluePrints(bluePrints):
               
                state.saveChanges()
                
                for item in bluePrints {
                    let exercise = Exercise()
                    state.workout.appendExercise(exercise)
                    exercise.template = item
                    exercise.repCountUnit = item.preferredRepCountUnit()
                    exercise.workout = state.workout
                    item.frequency += 1 // Improving the search results
                    
                    state.exercisesList.exercises.insert(ExerciseRow.State(exercise: exercise), at: 0)
                }
                
                return .none
                
            case .cancelButtonTapped:
                return .concatenate(
                    .send(.delegate(.activeWorkoutChanged(state.workout))),
                    .send(.delegate(.collapse)), // Collapse the bottom sheet
                    .send(.reset)              // Reset the state
                )
                
            case let .exercisesList(.delegate(.delete(exercise))):
                state.workout.deleteExercise(exercise: exercise.exercise)
                state.exercisesList.exercises.remove(id: exercise.id)
                return .none
                
            case .exercisesList:
                return .none
                
            case .finishButtonTapped:
                state.workout.endDate = self.now
                let sessionTime = state.sessionStartDate.distance(to: self.now)
                state.workout.duration += sessionTime
                return .concatenate(
                    .send(.delegate(.workoutSaved)),
                    .send(.delegate(.activeWorkoutChanged(state.workout))),
                    .send(.delegate(.collapse)),
                    .send(.reset)
                )  // TODO: Close
                
            case let .nameChanged(text):
                state.workout.name = text
                return .none
                
                // MARK: Action Handler for Navigation stack
            case let .path(element):
                switch element {
                case let .element(id: id, action: .exerciseLists(.delegate(.popToRoot))):
                    state.path.pop(from: id)
                    return .none
                case let .element(id: _, action: .exerciseLists(.delegate(.didSelectBluePrints(bluePrints)))):
                    return .send(.addSelectedBluePrints(bluePrints: bluePrints))
                default:
                    return .none
                }
                
            case .reset:
                state.workout = Workout()           // Reset the current workout
                state.exercisesList = .init()       // Reset exercise list
                state.isWorkoutSaved = false        // New workout is not saved
                state.isWorkoutInProgress = false   // Current workout is not active
                return .send(.delegate(.activeWorkoutChanged(state.workout)))
                
            case .saveChanges:
                // TODO: Check for improvements
                @Dependency(\.workoutDatabase) var database
                
                guard state.isWorkoutSaved.not() else {return .none}
                do {
                    try database.add(state.workout)
                    state.isWorkoutSaved = true
                    state.isWorkoutInProgress = true
                } catch {
                    Logger.action.error("\(error)")
                }
                return .none
                
            case .showExerciseListButtonTapped:
                state.path.append(.exerciseLists(ExerciseBluePrintsList.State()))
                return .none
                
            case .delegate(.toggleBottomSheet):
                return .send(.delegate(.activeWorkoutChanged(state.workout)))
            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .onChange(of: \.path) { _, newValue in
            Reduce { state, action in
                // MARK: Show/Hide Tabbar & Change BottomSheet size when we have items in navigation stack
                if newValue.isEmpty {
                    /// Make bottom sheet non-resizable/ non-collapsible
                    /// Make custom tabbar hidden to show full screen view
                    return .send(.delegate(.isBottomSheetCollapsible(true)))
                } else {
                    /// Make bottom sheet resizable/collapsible
                    /// Make custom tabbar visible
                    return .send(.delegate(.isBottomSheetCollapsible(false)))
                }
            }
        }
    }
}
