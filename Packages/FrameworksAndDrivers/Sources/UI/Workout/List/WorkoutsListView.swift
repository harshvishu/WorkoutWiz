//
//  WorkoutsListView.swift
//
//
//  Created by harsh vishwakarma on 23/12/23.
//

import SwiftUI
import Domain
import ApplicationServices
import Persistence
import DesignSystem
import OSLog
import SwiftData
import ComposableArchitecture


enum Filter: Equatable {
    case none(limit: Int? = nil)
    case today(limit: Int? = nil)
    case date(Date, limit: Int? = nil)
    case dates(date1: Date, date2: Date, limit: Int? = nil)
}

@Reducer
public struct WorkoutsListFeature {
    @ObservableState
    public struct State: Equatable {
        var workouts: [Workout] = []
        var grouping: Bool = false
        
        public init() {
            fetchWorkouts()
        }
        
        // Database ops
        mutating func fetchWorkouts() {
            @Dependency(\.workoutDatabase.fetchAll) var context
            do {
                self.workouts = try context()
            } catch {
                print(error)
                self.workouts = []
            }
        }
        
        mutating func deleteWorkout(_ workout: Workout) {
            @Dependency(\.workoutDatabase.delete) var delete
            do {
                try delete(workout)
            } catch {
                print(error)
                self.workouts = []
            }
        }
    }
    
    public enum Action {
        case delegate(Delegate)
        case fetchWorkouts
        case delete(workout: Workout)
        
        @CasePathable
        public enum Delegate {
            case editWorkout(Workout)
            case workoutListInvalidated
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .delegate(action):
                switch action {
                case .workoutListInvalidated:
                    return .send(.fetchWorkouts)
                case .editWorkout(_):
                    // update that particular workout
                    return .none
                }
            case .fetchWorkouts:
                state.fetchWorkouts()
                return .none
            case let .delete(workout):
                state.deleteWorkout(workout)
                return .send(.delegate(.workoutListInvalidated), animation: .default)
            }
        }
    }
}

struct WorkoutsListView: View {
    
    @Environment(\.isPresented) var isPresented
    @Environment(RouterPath.self) var routerPath
    
    let store: StoreOf<WorkoutsListFeature>
    
    var body: some View {
            
            Section {
                ForEach(store.workouts, id: \.id) { workout in
                    WorkoutRowView(workout: workout)
                        .onTapGesture {
                            store.send(.delegate(.editWorkout(workout)), animation: .default)
                        }
                }
                .onDelete(perform: delete)
                
                Button(action: {
                    // TODO:
//                    appState.send(.openEditWorkoutSheet)
                }, label: {
                    VStack {
                        Text("No workouts for today!")
                            .font(.title3)
                        Text("Tap to start a workout")
                            .font(.headline)
                    }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                })
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .opacity(store.workouts.isEmpty ? 1 : 0)
                
            } header: {
                HStack {
                    Text("Today")
                    
                    Spacer()
                    
                    Button {
                        // TODO: 
//                        appState.send(.showLogs)
                    } label: {
                        Text("All Entries")
                    }
                    .foregroundStyle(.primary)
                }
            }
            .listRowSeparator(.hidden)
            .onAppear {
                store.send(.fetchWorkouts)
            }
            
            /*
             switch viewState {
             case .loading:
                ProgressView()
                    .task {
                        bindModelContext()
                        await viewModel.listWorkouts()
                    }
            case .displayGrouped(let groupByDay):
                ForEach(groupByDay.sorted(by: { $0.key > $1.key }), id: \.key) { day, workouts in
                    Text(day, style: .date)
                        .id(day.formatted(.dateTime))
                        .print(day.formatted(.dateTime))
                    
                    ForEach(workouts, id: \.id) { workout in
                        WorkoutRowView(workout: workout)
                            .onTapGesture {
                                routerPath.navigate(to: .workoutDetails(workout: workout))
                            }
                        //                        .id($0.documentID)
                    }
                    .onDelete(perform: delete)
                }
                .onReceive(appState.signal) {
                    if case .workoutFinished = $0 {
                        Task {
                            await viewModel.listWorkouts()
                        }
                    }
                }
            case .display(let workouts):
                Section {
                    ForEach(workouts, id: \.id) { workout in
                        WorkoutRowView(workout: workout)
                            .onTapGesture {
                                appState.send(.openWorkout(workout))
                            }
                    }
                    .onDelete(perform: delete)
                    
                } header: {
                    // TODO: Change header based on data
                    HStack {
                        Text("Today")
                        
                        Spacer()
                        
                        Button {
                            appState.send(.showLogs)
                        } label: {
                            Text("All Entries")
                            // TODO: Fixme Should not be seen in Calnedar View
                        }
                        .foregroundStyle(.primary)
                    }
                    .foregroundStyle(.primary)
                    .font(.headline)
                }
                .onReceive(appState.signal) {
                    if case .workoutFinished = $0 {
                        Task {
                            await viewModel.listWorkouts()
                        }
                    }
                }
            case .empty:
                Section {
                    Button(action: {
                        appState.send(.openEditWorkoutSheet)
                    }, label: {
                        VStack {
                            Text("No workouts for today!")
                                .font(.title3)
                            Text("Tap to start a workout")
                                .font(.headline)
                        }
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                    })
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                } header: {
                    HStack {
                        Text("Today")
                        
                        Spacer()
                        
                        Button {
                            appState.send(.showLogs)
                        } label: {
                            Text("All Entries")
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .listRowSeparator(.hidden)
                .onReceive(appState.signal) {
                    if case .workoutFinished = $0 {
                        Task {
                            await viewModel.listWorkouts()
                        }
                    }
                }
            }
            */
    }
}

fileprivate extension WorkoutsListView {
    func delete(at indexSet: IndexSet) {
        for index in indexSet {
            let workout = store.workouts[index]
            store.send(.delete(workout: workout))
        }
    }
}

#Preview {
    return WorkoutsListView(
        store: StoreOf<WorkoutsListFeature>(
            initialState: WorkoutsListFeature.State(),
            reducer: {
                WorkoutsListFeature()
            }
        )
    )
    .withPreviewEnvironment()
}
