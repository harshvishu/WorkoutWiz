//
//  File.swift
//
//
//  Created by harsh vishwakarma on 19/11/23.
//

import SwiftUI
import OSLog
import Persistence
import DesignSystem
import SwiftData
import Domain
import ComposableArchitecture

/**
 Reducer responsible for managing the state and actions of the main features of the application.
 */
@Reducer
public struct AppFeature {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        
        public init() {}
        
        /// Represents the state of the tab bar feature.
        var tabs = TabBarFeature.State()
        
        /// Represents the state of the popup presenter feature.
        var popup = PopupPresenter.State()
    }
    
    public enum Action {
        /// Actions related to the tab bar feature.
        case tabs(TabBarFeature.Action)
        
        /// Actions related to the popup presenter feature.
        case popup(PopupPresenter.Action)
    }
    
    public var body: some ReducerOf<Self> {
        // Scope for managing the state and actions related to the tab bar feature
        Scope(state: \.tabs, action: \.tabs) {
            TabBarFeature()
        }
        
        // Scope for managing the state and actions related to the popup presenter feature
        Scope(state: \.popup, action: \.popup) {
            PopupPresenter()
        }
        
        Reduce { state, action in
            switch action {
            case .popup:
                return .none
                
                // MARK: - Handling WorkoutEditor Action
                /// If the action is related to the tab bar feature and involves the workoutEditor path
            case let .tabs(.workoutEditor(.exercisesList(.exercises(exercises)))):
                
                /// Extract specific actions from the exercisesList delegate
                switch exercises {
                case let .element(id: exerciseID, action: .delegate(.addNewSet)):
                    /// If a new set is to be added to an exercise, extract the exercise and send a corresponding popup action
                    if let exercise = state.tabs.workoutEditor.exercisesList.exercises[id: exerciseID]?.exercise {
                        return .send(.popup(.addNewSet(toExercise: exercise)))
                    }
                    return .none
                case let .element(id: exerciseID, action: .delegate(.editSet(rep))):
                    /// If a set within an exercise is to be edited, extract the exercise and rep information and send a corresponding popup action
                    if let exercise = state.tabs.workoutEditor.exercisesList.exercises[id: exerciseID]?.exercise {
                        return .send(.popup(.editSet(forExercise: exercise, rep: rep)))
                    }
                    return .none
                case .element:
                    // Add handling for other delegates here if needed
                    return .none
                }
                // MARK: - Handling CalendarTab actions
                /// If the action is related to the tab bar feature and involves the calendar path
                /// Extract the exercise ID and send a corresponding popup action
                /// Using the subscript for a succinct syntax get the `WorkoutEditor` state
                /// `state.tabs.calendar.path[id: id, case: \.workout]`
            case let .tabs(.calendar(.path(.element(id: id, action: .workout(.exercisesList(.exercises(.element(id: exerciseID, action: .delegate(delegateAction))))))))):
                switch delegateAction {
                case .addNewSet:
                    // Add new rep
                    if let exercise = state.tabs.calendar.path[id: id, case: \.workout]?.exercisesList.exercises[id: exerciseID]?.exercise {
                        return .send(.popup(.addNewSet(toExercise: exercise)))
                    }
                    return .none
                case let .editSet(rep):
                    // Edit existing rep
                    if let exercise = state.tabs.calendar.path[id: id, case: \.workout]?.exercisesList.exercises[id: exerciseID]?.exercise {
                        return .send(.popup(.editSet(forExercise: exercise, rep: rep)))
                    }
                    return .none
                case .delete:
                    /// No need to handle this action here
                    return .none
                case .showTemplateDetails:
                    /// No need to handle this action here
                    /// This is handled in ``CalendarTab``
                    return .none
                }
                // For other tab bar actions, return .none
            case .tabs:
                return .none
            }
        }
    }
}

public protocol WorkoutWizApp : App {
    var store: StoreOf<AppFeature> {get}
}

/// The entry point to the WorkoutWiz app.
/// The concrete implementation is in the WorkoutWizApp parent app.
public extension WorkoutWizApp {
    
    var tabBarStore: StoreOf<TabBarFeature> { store.scope(state: \.tabs, action: \.tabs) }
    var popupStore: StoreOf<PopupPresenter> { store.scope(state: \.popup, action: \.popup) }
    
    @MainActor
    var body: some Scene {
        WindowGroup {
            RootView(tabBarStore: tabBarStore, popupStore: popupStore)
                .task {Logger.ui.log("Welcome to WorkoutWiz!")}
                .withAppEnvironment()
        }
    }
}
