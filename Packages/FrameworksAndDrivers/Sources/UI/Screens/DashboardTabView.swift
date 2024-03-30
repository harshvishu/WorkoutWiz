//
//  DashboardTabView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 17/11/23.
//

import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import Domain
import OSLog
import ComposableArchitecture

@Reducer
public struct DashboardTab {
    public struct State: Equatable {
        var dashboard = DashboardFeature.State()
    }
    
    public enum Action {
        case dashboard(DashboardFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.dashboard, action: \.dashboard) {
            DashboardFeature()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .dashboard:
                return .none
            }
        }
    }
}

struct DashboardTabView: View {
    let store: StoreOf<DashboardTab>
    
    public var body: some View {
        NavigationStack {
            DashboardView(store: store.scope(state: \.dashboard, action: \.dashboard))
        }
    }
}

#Preview {
    DashboardTabView(store: StoreOf<DashboardTab>(
        initialState: DashboardTab.State()
    ) {
        DashboardTab()
    })
    .withPreviewEnvironment()
}
