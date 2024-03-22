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
        
        var path = StackState<Path.State>()
        var exercisesList = ExercisesList.State()
        
        
        init(isWorkoutSaved: Bool, isWorkoutInProgress: Bool) {
            @Dependency(\.workoutDatabase.fetchAll) var fetchAll
            _ = try? fetchAll()
            self.workout = Workout()
            self.isWorkoutSaved = isWorkoutSaved
            self.isWorkoutInProgress = isWorkoutInProgress
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
            case navigationStackNonEmpty
            case navigationStackIsEmpty
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
                    state.workout.exercises.append(exercise)
                    exercise.template = item
                    exercise.repCountUnit = item.preferredRepCountUnit()
                    exercise.workout = state.workout
                    item.frequency += 1 // Improving the search results
                    
                    state.exercisesList.exercises.append(ExerciseRow.State(exercise: exercise))
                }
                
                return .none
                
            case .cancelButtonTapped:
                return .concatenate(
                    .send(.reset),              // Reset the state
                    .send(.delegate(.collapse)) // Collapse the bottom sheet
                )
            case .exercisesList:
                
                return .none
            case .finishButtonTapped:
                state.workout.endDate = self.now
                state.workout.duration = state.workout.startDate.distance(to: self.now)
                return .concatenate(.send(.delegate(.workoutSaved)), .send(.delegate(.collapse)), .send(.reset))  // TODO: Close
                
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
                state.isWorkoutSaved = false        // New workout is not saved
                state.isWorkoutInProgress = false   // Current workout is not active
                return .none
                
            case .saveChanges:
                // TODO: Pending
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
            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .onChange(of: \.path) { _, newValue in
            Reduce { state, action in
                if newValue.isEmpty {
                    return .send(.delegate(.navigationStackIsEmpty))
                } else {
                    return .send(.delegate(.navigationStackNonEmpty))
                }
            }
        }
    }
}
