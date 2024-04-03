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
        var workoutsGroupedByDay: [Date : [Workout]] = [:]
        
        var searchQuery: String = ""
        var fetchDescriptor: FetchDescriptor<Workout> {
            var descriptor = FetchDescriptor(predicate: self.predicate, sortBy: self.sort)
//            descriptor.fetchLimit = fetchLimit
            // TODO: Fix Fetch Limit Issue
            descriptor.fetchOffset = fetchOffset
            return descriptor
        }
        
        var predicate: Predicate<Workout>? {
            let (startDate, endDate) = filter.dates()
            
            return #Predicate {
                $0.startDate > startDate && $0.startDate < endDate && searchQuery.isEmpty ? true : $0.name.localizedStandardContains(searchQuery)
            }
        }
        
        var sort: [SortDescriptor<Workout>] {
            return [
                self.dateSort?.descriptor,
                self.nameSort?.descriptor,
                self.uuidSort?.descriptor
            ].compactMap { $0 }
        }
        
        var dateSort: DateSort? = .reverse
        public enum DateSort {
            case forward, reverse
            var descriptor: SortDescriptor<Workout> {
                switch self {
                case .forward:
                    return .init(\.startDate, order: .forward)
                case .reverse:
                    return .init(\.startDate, order: .reverse)
                }
            }
        }
        
        var nameSort: NameSort?
        public enum NameSort {
            case forward, reverse
            var descriptor: SortDescriptor<Workout> {
                switch self {
                case .forward:
                    return .init(\.name, order: .forward)
                case .reverse:
                    return .init(\.name, order: .reverse)
                }
            }
        }
        
        var uuidSort: UUIDSort?
        enum UUIDSort {
            case forward, reverse
            var descriptor: SortDescriptor<Workout> {
                switch self {
                case .forward: return .init(\.id, order: .forward)
                case .reverse: return .init(\.id, order: .reverse)
                }
            }
        }
        
        var fetchOffset = 0
        var visibleWorkoutsLimit: Int? {
            filter.fetchLimit()
        }
        var fetchLimit = 10
        var canFetchMore = true
        var isSearchFieldFocused: Bool = false
        var filter: WorkoutListFilter = .none
        
        var activeWorkoutID: UUID?
        
        public init(filter: WorkoutListFilter = .none, grouping: Bool = false) {
            self.filter = filter
            self.grouping = grouping
        }
        
        // Database ops
        fileprivate mutating func fetchWorkouts() -> [Workout] {
            @Dependency(\.workoutDatabase.fetch) var fetch
            do {
                return try fetch(fetchDescriptor)
            } catch {
                Logger.state.error("\(error)")
                return []
            }
        }
        
        fileprivate mutating func deleteWorkout(_ workout: Workout) {
            @Dependency(\.workoutDatabase.delete) var delete
            do {
                try delete(workout)
            } catch {
                // Unable to delete
                print(error)
            }
        }
    }
    
    public enum Action {
        case delete(workout: Workout)
        case fetchWorkouts
        case showAllEntriesButtonTapped
        case setFilter(WorkoutListFilter)
        
        case delegate(Delegate)
        @CasePathable
        public enum Delegate {
            case editWorkout(Workout)
            case workoutListInvalidated
            case startNewWorkout
            case showCalendarScreen
        }
    }
    
    // MARK: - Dependencies
    @Dependency(\.saveData) var saveData
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
           
            case .fetchWorkouts:
                let fetchResults = state.fetchWorkouts()
//                let fetchLimit = state.fetchLimit // TODO:
                
                state.workouts += fetchResults
                state.fetchOffset += fetchResults.count
                
                if let visibleWorkoutsLimit = state.visibleWorkoutsLimit {
                    if state.workouts.count > visibleWorkoutsLimit {
                        let difference = state.workouts.count - visibleWorkoutsLimit
                        if state.dateSort == .reverse {
                            state.workouts.removeLast(difference)
                        } else {
                            state.workouts.removeFirst(difference)
                        }
                        state.canFetchMore = false
                    }
                }
                
                if fetchResults.isEmpty {
                    state.canFetchMore = false
                }
                return .none
                
                // MARK: Deleting workout
                // TODO: Add alert confirmation
            case let .delete(workout):
                if state.activeWorkoutID == workout.id {
                    return .none
                }
                
                state.deleteWorkout(workout)
                return .send(.delegate(.workoutListInvalidated), animation: .default)
                
            case .showAllEntriesButtonTapped:
                return .send(.delegate(.showCalendarScreen), animation: .customSpring())
                
            case let .setFilter(filter):
                state.filter = filter
                return .send(.delegate(.workoutListInvalidated))
                
                // MARK: Handle Delegate actions
            case let .delegate(action):
                switch action {
                case .workoutListInvalidated:
                    state.workouts = []
                    state.canFetchMore = true
                    state.fetchOffset = 0
                    return .send(.fetchWorkouts)
                case .editWorkout(_):
                    // TODO: update that particular workout
                    return .none
                case  .startNewWorkout, .showCalendarScreen:
                    return .none
                }
            }
        }
        .onChange(of: \.workouts) { _, _ in
            Reduce { state, _ in
                let calendar = Calendar.autoupdatingCurrent
                let workoutsGroupedByDay = Dictionary(grouping: state.workouts) {
                    calendar.startOfDay(for: $0.startDate)
                }
                state.workoutsGroupedByDay = workoutsGroupedByDay
                return .none
            }
        }
    }
}

struct WorkoutsListView: View {
    
    @Environment(\.isPresented) var isPresented
    
    let store: StoreOf<WorkoutsListFeature>
    
    var body: some View {
        ScrollToView()
            .onAppear {
                store.send(.delegate(.workoutListInvalidated))
            }
        
        if store.grouping {
            ForEach(store.workoutsGroupedByDay.sorted(by: { $0.key > $1.key }), id: \.key) { day, workouts in
                Text(day, style: .date)
                    .id(day.formatted(.dateTime))
                
                ForEach(workouts, id: \.id) { workout in
                    WorkoutRowView(workout: workout)
                        .onTapGesture {
                            store.send(.delegate(.editWorkout(workout)), animation: .default)
                        }
                }
            }
        } else {
            Text("Today")
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            ForEach(store.workouts, id: \.id) { workout in
                WorkoutRowView(workout: workout)
                    .onTapGesture {
                        store.send(.delegate(.editWorkout(workout)), animation: .default)
                    }
                    .deleteDisabled(store.activeWorkoutID == workout.id)
            }
            .onDelete(perform: delete)
            
            // TODO: Improve
            if store.workouts.isNotEmpty {
                Button {
                    store.send(.showAllEntriesButtonTapped, animation: .customSpring())
                } label: {
                    Text("View all entries for today")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
                .foregroundStyle(.secondary)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            
            if store.workouts.isEmpty {
                Button(action: {
                    store.send(.delegate(.startNewWorkout))
                }, label: {
                    EmptyStateView(title: "No Workouts", subtitle: "Tap to start a new workout.", resource: .placeholderQuestion)
                    .frame(height: 200)
                })
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
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
//
//#Preview {
//    return WorkoutsListView(
//        store: StoreOf<WorkoutsListFeature>(
//            initialState: WorkoutsListFeature.State(),
//            reducer: {
//                WorkoutsListFeature()
//            }
//        )
//    )
//    .withPreviewEnvironment()
//}
