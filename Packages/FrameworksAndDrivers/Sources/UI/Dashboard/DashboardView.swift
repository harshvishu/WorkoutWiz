//
//  DashboardView.swift
//
//
//  Created by harsh vishwakarma on 29/12/23.
//

import SwiftUI
import Domain
import ApplicationServices
import Persistence
import DesignSystem
import OSLog
import SwiftData
import ComposableArchitecture

@Reducer
public struct DashboardFeature {
    
    public struct State: Equatable {
        var workoutsList = WorkoutsListFeature.State()
    }
    
    public enum Action {
        case workoutsList(WorkoutsListFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.workoutsList, action: \.workoutsList) {
            WorkoutsListFeature()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case let .workoutsList(.delegate(.editWorkout(workout))):
                return .none
            case .workoutsList:
                return .none
            }
        }
    }
}

struct DashboardView: View {
    
    init(store: StoreOf<DashboardFeature>) {
        self.store = store
    }
    
    let store: StoreOf<DashboardFeature>
    
    @Environment(\.isPresented) var isPresented
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ZStack {
                    List {
                        WorkoutsListView(store: store.scope(state: \.workoutsList, action: \.workoutsList))
                    }
                    .listStyle(.plain)
                    .listSectionSeparator(.hidden)
                }
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Image(.equipment4)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 42, height: 42)
                        .clipShape(Circle())
                    
                    VStack {
                        Text("Hi, Harsh")
                            .font(.title3.bold())
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Image(systemName: "bell.badge.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.accentColor, Color.primary.opacity(0.64))
                        .symbolEffect(.pulse.byLayer, value: isPresented)
                }
            }
        }
    }
}

#Preview {
    @State var appscreen = AppScreen.dashboard
    @State var store = StoreOf<TabBarFeature>(initialState: TabBarFeature.State(), reducer: {
        TabBarFeature()
    })
    
    return NavigationStack {
        ZStack(alignment: .bottom) {
            DashboardView(store: store.scope(state: \.dashboard, action: \.dashboard).scope(state: \.dashboard, action: \.dashboard))
                .previewBorder()
            CustomTabBar(store: store)
        }
        .withPreviewEnvironment()
    }
}
