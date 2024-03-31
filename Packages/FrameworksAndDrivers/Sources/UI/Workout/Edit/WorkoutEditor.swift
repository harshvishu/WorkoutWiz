//
//  WorkoutEditor.swift
//  
//
//  Created by harsh vishwakarma on 08/03/24.
//

import Domain
import SwiftUI
import ComposableArchitecture
import OSLog

@Reducer
public struct WorkoutEditor {
    
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
        var isNewWorkout: Bool
        
        var path = StackState<Path.State>()
        var exercisesList: ExercisesList.State
        
        init() {
            @Dependency(\.workoutDatabase.fetchAll) var fetchAll
            _ = try? fetchAll()
            self.workout = Workout()
            self.isWorkoutSaved = false
            self.isWorkoutInProgress = false
            self.isNewWorkout = true
            
            self.exercisesList = .init()
            self.sessionStartDate = .init()
        }
        
        init(isWorkoutSaved: Bool, isWorkoutInProgress: Bool, workout: Workout) {
            self.workout = workout
            self.isWorkoutSaved = isWorkoutSaved
            self.isWorkoutInProgress = isWorkoutInProgress
            self.isNewWorkout = false
            
            let exercises = IdentifiedArray(
                uniqueElements: workout.exercises
                    .map({ExerciseRow.State(exercise: $0)})
                    .sorted(using: KeyPathComparator(\.exercise.sortOrder, order: .forward))    // use forward for decending order
            )
            self.exercisesList = ExercisesList.State(exercises: exercises)
            self.sessionStartDate = .init()
        }
        
        mutating func saveWorkoutIfNotExistsAndStart() {
            @Dependency(\.workoutDatabase) var database
            
            if isWorkoutSaved.not() {
                do {
                    try database.add(workout)
                } catch {
                    Logger.action.error("\(error)")
                    return
                }
            }
            
            isWorkoutSaved = true
            isWorkoutInProgress = true
        }
        
        mutating func deleteWorkout() {
            @Dependency(\.workoutDatabase) var database
            
            if isWorkoutSaved {
                do {
                    try database.delete(workout)
                } catch {
                    Logger.action.error("\(error)")
                    return
                }
            }
        }
    }
    
    public enum Action {
        case addSelectedBluePrints(bluePrints: [ExerciseBluePrint])
        case cancelButtonTapped
        case delegate(Delegate)
        case exercisesList(ExercisesList.Action)
        case finishButtonTapped
        case nameChanged(String)
        case path(StackAction<Path.State, Path.Action>)
        case showExerciseListButtonTapped
        case startWorkoutButtonTapped

        public enum Delegate {
            case collapse
            case expand
            case isBottomSheetResizable(Bool)
            case workoutSaved
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
               
                state.saveWorkoutIfNotExistsAndStart()
                
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
                state.isWorkoutInProgress = false
                if state.isNewWorkout {
                    // TODO: Use Undo manager and manual context save
                    state.deleteWorkout()               // Delete new workout
                    
                    return .concatenate(
                        .send(.delegate(.collapse))    // Collapse the bottom sheet
                    )
                }
                return .none
                
            case let .exercisesList(.delegate(.delete(exercise))):
                state.workout.deleteExercise(exercise: exercise.exercise)
                state.exercisesList.exercises.remove(id: exercise.id)
                return .none
                
            case .exercisesList:
                return .none
                
            case .finishButtonTapped:

                state.workout.endDate = self.now                // Set end date
                let sessionTime = state.sessionStartDate.distance(to: self.now)
                state.workout.duration += sessionTime           // Add the current session time
                state.isWorkoutInProgress = false
                
                if state.isNewWorkout {
                    return .concatenate(.send(.delegate(.workoutSaved)), .send(.delegate(.collapse)))
                }
                
                return .send(.delegate(.workoutSaved))
                
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
                
            case .showExerciseListButtonTapped:
                state.path.append(.exerciseLists(ExerciseBluePrintsList.State()))
                return .none
                
            case .startWorkoutButtonTapped:
                if state.isNewWorkout {
                    state.workout.startDate = .now
                }
                state.isWorkoutInProgress = true
                if state.exercisesList.exercises.isEmpty {
                    return .send(.showExerciseListButtonTapped, animation: .default)
                }
                return .none
                
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
                    return .send(.delegate(.isBottomSheetResizable(true)))
                } else {
                    /// Make bottom sheet resizable/collapsible
                    /// Make custom tabbar visible
                    return .send(.delegate(.isBottomSheetResizable(false)))
                }
            }
        }
    }
}
