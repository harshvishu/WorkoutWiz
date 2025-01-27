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
        var workoutsList = WorkoutsList.State(filter: .today(limit: 1))
    }
    
    public enum Action {
        case workoutsList(WorkoutsList.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.workoutsList, action: \.workoutsList) {
            WorkoutsList()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .workoutsList:
                return .none
            }
        }
    }
}

struct DashboardTabView: View {
    
    init(store: StoreOf<DashboardTab>) {
        self.store = store
    }
    
    let store: StoreOf<DashboardTab>
    
    @Environment(\.isPresented) var isPresented
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { proxy in
                    ZStack {
                        List {
                            WorkoutsListView(store: store.scope(state: \.workoutsList, action: \.workoutsList))
                        }
                        .environment(\.defaultMinListRowHeight, 0)
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
}

@available(iOS 18.0, *)
#Preview {
    @State var appscreen = AppScreen.dashboard
    @State var store = StoreOf<TabBarFeature>(initialState: TabBarFeature.State(), reducer: {
        TabBarFeature()
    })
    let container = SwiftDataModelConfigurationProvider.shared.container
    
    return NavigationStack {
        ZStack(alignment: .bottom) {
            DashboardTabView(store: store.scope(state: \.dashboard, action: \.dashboard))
                .previewBorder()
            CustomTabBar(store: store)
        }
        .modelContainer(container)
    }
}
