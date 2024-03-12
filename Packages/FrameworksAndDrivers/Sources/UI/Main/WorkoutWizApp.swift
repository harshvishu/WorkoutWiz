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
        // TODO: check
        var tabs = TabBarFeature.State()
        
        public init() {
            self.tabs = TabBarFeature.State()
        }
    }
    
    public enum Action {
        case tabs(TabBarFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.tabs, action: \.tabs) {
            TabBarFeature()
        }
        
        Reduce { state, action in
            switch action {
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
    
    @MainActor
    var body: some Scene {
        WindowGroup {
            RootView(store: store.scope(state: \.tabs, action: \.tabs))
                .task {Logger.ui.log("Welcome to WorkoutWiz!")}
                .withAppEnvironment()
        }
    }
}
