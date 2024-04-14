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
    /**
     An inner reducer enum `Destination` for manging alerts and presentations.
     */
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)
        
        @CasePathable
        public enum Alert {
            case confirmDelete
            case cancelDelete
        }
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        
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
        var workoutToBeDeleted: UUID?
        
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
            workoutToBeDeleted = nil
        }
    }
    
    public enum Action {
        /// Deletes the workout. Use with caution as this action is irreversible.
        /// - Warning: This action is irreversible. Make sure you want to permanently delete the workout.
        @available(*, message: "Use with caution as this action is irreversible. Do not call directly Use `deleteButtonTapped` instead")
        case delete(workout: Workout)
        case deleteButtonTapped(workout: Workout)
        
        case destination(PresentationAction<Destination.Action>)
        
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
                // let fetchLimit = state.fetchLimit // TODO:
                /// TODO: Move the workouts to individual Feature like `ExerciseRow` and then move alerts within each State
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
                
            case .deleteButtonTapped(let workout):
                state.workoutToBeDeleted = workout.id
                state.destination = .alert(.deleteWorkout(workout: workout))
                return .none
                
            case let .delete(workout):
                if state.activeWorkoutID == workout.id {
                    return .none
                }
                
                state.deleteWorkout(workout)
                return .send(.delegate(.workoutListInvalidated), animation: .default)
                
            case let .destination(.presented(.alert(dialog))):
                switch dialog {
                case .confirmDelete:
                    return .run { [workoutToBeDeleted = state.workoutToBeDeleted, workouts = state.workouts] send in
                        if let workout = workouts.first(where: {$0.id == workoutToBeDeleted}) {
                            await send(.delete(workout: workout))
                        }
                    }
                case .cancelDelete:
                    return .none
                }
            case .destination:
                return .none
                
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
                    return .send(.fetchWorkouts, animation: .default)
                case .editWorkout(_):
                    // TODO: update that particular workout
                    return .none
                case  .startNewWorkout, .showCalendarScreen:
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
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

/**
 A view struct `WorkoutsListView` for displaying a list of workouts.
 */
struct WorkoutsListView: View {
    /// Environment variable to check if the view is presented.
    @Environment(\.isPresented) var isPresented
    /// The store of `WorkoutsListFeature`.
    @Bindable var store: StoreOf<WorkoutsListFeature>
    
    var body: some View {
        // Scroll to view
        ScrollToView()
            .onAppear {
                // Send a delegate action to invalidate the workout list
                store.send(.delegate(.workoutListInvalidated))
            }
        
        // MARK:  Grouped workouts
        if store.grouping {
            
            // Loop through each day and its associated workouts
            ForEach(store.workoutsGroupedByDay.sorted(by: { $0.key > $1.key }), id: \.key) { day, workouts in
                // Display the day
                Text(day, style: .date)
                    .id(day.formatted(.dateTime))
                
                workoutsList(workouts: workouts)
            }
        } else {
            // TODO: Move to Dashboard
            // MARK: "Today"
            Text("Today")
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            workoutsList(workouts: store.workouts)
            
            // button to view all entries for today if workouts are available
            if store.workouts.isNotEmpty {
                Button {
                    // Send a delegate action to show all entries for today
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
            
            // Display a button to start a new workout if no workouts are available
            if store.workouts.isEmpty {
                Button(action: {
                    // Send a delegate action to start a new workout
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
    
    /**
     Deletes workouts at the specified indices.
     - Parameter indexSet: The indices of workouts to delete.
     */
    private func delete(at indexSet: IndexSet) {
        for index in indexSet {
            let workout = store.workouts[index]
            store.send(.delete(workout: workout))
        }
    }
    
    @ViewBuilder
    private func workoutsList(workouts: [Workout]) -> some View {
        ForEach(workouts, id: \.id) { workout in
            WorkoutRowView(workout: workout)
                .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
                .onTapGesture {
                    // Send a delegate action to edit the workout
                    store.send(.delegate(.editWorkout(workout)), animation: .default)
                }
                .contextMenu {
                    Button {
                        store.send(.deleteButtonTapped(workout: workout))
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(store.activeWorkoutID == workout.id)   // Disable delete if the workout is active
                    
                    Button {
                        // TODO: Duplicate workout
                        print("TODO: Duplicate")
                    } label: {
                        Label("Duplicate", systemImage: "doc.on.doc.fill")
                    }
                }
        }
    }
}

extension AlertState where Action == WorkoutsListFeature.Destination.Alert {
    static func deleteWorkout(workout: Workout) -> Self {
        Self {
            TextState("Delete \(workout.name)?")
        } actions: {
            ButtonState(role: .destructive, action: .confirmDelete) {
                TextState("Yes")
            }
            ButtonState(role: .cancel, action: .cancelDelete) {
                TextState("Nevermind")
            }
        } message: {
            TextState("Are you sure you want to delete this workout?")
        }
    }
}

#Preview {
    let container = SwiftDataModelConfigurationProvider.shared.container
    return WorkoutsListView(
        store: StoreOf<WorkoutsListFeature>(
            initialState: WorkoutsListFeature.State(),
            reducer: {
                WorkoutsListFeature()
            }
        )
    )
    .modelContainer(container)
}
