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

@Reducer
public struct AppFeature {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        var tabs = TabBarFeature.State()
        var popup = PopupPresenter.State()
    }
    
    public enum Action {
        case tabs(TabBarFeature.Action)
        case popup(PopupPresenter.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.tabs, action: \.tabs) {
            TabBarFeature()
        }
        
        Scope(state: \.popup, action: \.popup) {
            PopupPresenter()
        }
        
        Reduce { state, action in
            switch action {
            case .popup:
                return .none
            case let .tabs(.workoutEditor(.exercisesList(.exercises(exercises)))):
                switch exercises {
                case let .element(id: exerciseID, action: .delegate(.addNewSet)):
                    if let exercise = state.tabs.workoutEditor.exercisesList.exercises[id: exerciseID]?.exercise {
                        return .send(.popup(.addNewSet(toExercise: exercise)))
                    }
                    return .none
                case let .element(id: exerciseID, action: .delegate(.editSet(rep))):
                    if let exercise = state.tabs.workoutEditor.exercisesList.exercises[id: exerciseID]?.exercise {
                        return .send(.popup(.editSet(forExercise: exercise, rep: rep)))
                    }
                    return .none
                }
            case .tabs(.delegate(.showLogs)):
                state.tabs.currentTab = .logs
                return .none
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
