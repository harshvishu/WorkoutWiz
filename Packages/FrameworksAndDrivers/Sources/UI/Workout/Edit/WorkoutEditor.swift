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

/**
 A reducer struct `WorkoutEditor` that manages the state and actions related to the workout editor.
 */
@Reducer
public struct WorkoutEditor {
    
    // MARK: - Inner Reducer for Path
    
    /**
     An inner reducer enum `Path` for managing navigation stack actions and states.
     */
    @Reducer(state: .equatable)
    public enum Path {
        case exerciseLists(ExerciseBluePrintsList)
        case exerciseDetails(ExerciseBluePrintDetails)
    }
    
    // MARK: - Inner Reducer for Destination
    
    /**
     An inner reducer enum `Destination` for managing alerts and presentations.
     */
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)
        
        /**
         An enum `Alert` defining alert actions for the workout editor.
         */
        @CasePathable
        public enum Alert {
            case confirmCancel
            case confirmDeleteWorkout
            case confirmSaveWorkout
        }
    }
    
    // MARK: - State
    
    /**
     A state struct `State` for managing workout editor related state variables.
     */
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        
        var workout: Workout
        var isWorkoutSaved: Bool
        var isWorkoutInProgress: Bool
        var sessionStartDate: Date
        var isNewWorkout: Bool
        var isTimerRunning: Bool = false    // TODO: Pending
        
        var path = StackState<Path.State>()
        var exercisesList: ExercisesList.State
        
        /**
         Initializes the state with default values.
         */
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
        
        /**
         Initializes the state with provided values.
         - Parameters:
         - isWorkoutSaved: A boolean indicating whether the workout is saved.
         - isWorkoutInProgress: A boolean indicating whether the workout is in progress.
         - workout: The workout object.
         */
        init(isWorkoutSaved: Bool, isWorkoutInProgress: Bool, workout: Workout) {
            self.workout = workout
            self.isWorkoutSaved = isWorkoutSaved
            self.isWorkoutInProgress = isWorkoutInProgress
            self.isNewWorkout = false
            
            let exercises = IdentifiedArray(
                uniqueElements: workout.exercises
                    .map({ExerciseRow.State(exercise: $0)})
                    .sorted(using: KeyPathComparator(\.exercise.sortOrder, order: .forward))    // use forward for descending order
            )
            self.exercisesList = ExercisesList.State(exercises: exercises)
            self.sessionStartDate = .init()
        }
        
        /**
         Saves the workout if not already saved and starts the workout session.
         */
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
        
        /**
         Add exercise to the workout.
         */
        mutating func addExercises(bluePrints: [ExerciseBluePrint]) {
            for item in bluePrints {
                let exercise = Exercise()
                workout.appendExercise(exercise)
                exercise.template = item
                exercise.repCountUnit = item.preferredRepCountUnit()
                exercise.workout = workout
                item.frequency += 1 // Sort by most frequent
                
                exercisesList.exercises.insert(ExerciseRow.State(exercise: exercise), at: 0)
            }
        }
        
        /**
         Delete exericse
         */
        mutating func deleteExercise(exerciseID: ObjectIdentifier) {
            guard let exercise = exercisesList.exercises[id: exerciseID]?.exercise else {return}
            workout.deleteExercise(exercise: exercise)
            exercisesList.exercises.remove(id: exerciseID)
        }
        
        /**
         Deletes the workout from the database.
         */
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
    
    // MARK: - Actions
    
    /**
     An enum `Action` defining the actions that can be performed in the workout editor.
     */
    public enum Action {
        case addSelectedBluePrints(bluePrints: [ExerciseBluePrint])
        case cancelButtonTapped
        case delegate(Delegate)
        case deleteButtonTapped
        
        /// Deletes the workout. Use with caution as this action is irreversible.
        /// - Warning: This action is irreversible. Make sure you want to permanently delete the workout.
        @available(*, message: "Use with caution as this action is irreversible. Do not call directly. Use `deleteButtonTapped` instead")
        case deleteWorkout
        case destination(PresentationAction<Destination.Action>)
        case exercisesList(ExercisesList.Action)
        case finishButtonTapped
        
        /// Terminates the workout session and makes changes permanent. Use with caution as this action is irreversible.
        /// - Warning: This action is irreversible. Make sure you want to finish the workout.
        @available(*, message: "Use with caution as this action is irreversible. Do not call directly. Use `finishButtonTapped` instead")
        case finishWorkout
        case nameChanged(String)
        case path(StackAction<Path.State, Path.Action>)
        case showExerciseListButtonTapped
        case startWorkoutButtonTapped
        
        /**
         An enum `Delegate` defining delegate actions for the workout editor.
         */
        @CasePathable
        public enum Delegate {
            case collapse
            case expand
            case isBottomSheetResizable(Bool)
            case workoutSaved
            case workoutDeleted
        }
    }
    
    // MARK: - Dependencies
    
    /**
     A dependency `now` for accessing the current date.
     */
    @Dependency(\.date.now) var now
    
    // MARK: - Reducer Body
    
    /**
     The body of the reducer, defining how actions modify the state.
     */
    public var body: some ReducerOf<Self> {
        
        Scope(state: \.exercisesList, action: \.exercisesList) {
            ExercisesList()
        }
        
        Reduce<State, Action> {
            state, action in
            
            switch action {
                
            case let .addSelectedBluePrints(bluePrints):
                
                state.saveWorkoutIfNotExistsAndStart()
                state.addExercises(bluePrints: bluePrints)
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
                
            case .deleteButtonTapped:
                state.destination = .alert(.deleteWorkout)
                return .none
                
            case .deleteWorkout:
                state.deleteWorkout()               // Delete workout
                return .none
                
                /// Handle delegate actions for each ExerciseRow from ExerciseList
                // MARK: - Delete exercise
            case let .exercisesList(.exercises(.element(id: exerciseID, action: .delegate(.delete)))):
                state.deleteExercise(exerciseID: exerciseID)
                return .none
                // MARK: - Handle Info button tapped on `Exercise Row Header`
            case let .exercisesList(.exercises(.element(id: exerciseID, action: .delegate(.showBluePrintDetails)))):
                guard let blueprint = state.exercisesList.exercises[id: exerciseID]?.exercise.template else {return .none}
                state.path.append(.exerciseDetails(.init(exercise: blueprint)))
                return .none
                
            case .exercisesList:
                return .none
                
            case .finishButtonTapped:
                guard state.workout.isValid() else {
                    state.destination = .alert(.saveInvalidWorkout)
                    return .none
                }
                return .send(.finishWorkout)
                
            case .finishWorkout:
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
                
                // MARK: Action Handler for Destination
            case let .destination(.presented(.alert(alertAction))):
                switch alertAction {
                case .confirmCancel:
                    return .none
                case .confirmDeleteWorkout:
                    return .run { send in
                        await send(.deleteWorkout)
                        await send(.delegate(.collapse))
                        await send(.delegate(.workoutDeleted))
                    }
                case .confirmSaveWorkout:
                    return .send(.finishWorkout)
                }
                
            case .destination:
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
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

extension AlertState where Action == WorkoutEditor.Destination.Alert {
    static let saveInvalidWorkout = Self {
        TextState("Save Workout?")
    } actions: {
        ButtonState(action: .confirmSaveWorkout) {
            TextState("Yes")
        }
        ButtonState(role: .cancel) {
            TextState("Nevermind")
        }
    } message: {
        TextState("You have few incomplete exercises. Are you sure you want to save this workout?")
    }
    
    static let deleteWorkout = Self {
        TextState("Delete Workout?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmDeleteWorkout) {
            TextState("Yes")
        }
        ButtonState(role: .cancel) {
            TextState("Nevermind")
        }
    } message: {
        TextState("Are you sure you want to delete this workout?")
    }
}
