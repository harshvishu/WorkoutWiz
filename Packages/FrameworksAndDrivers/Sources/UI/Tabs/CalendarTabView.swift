//
//  CalendarTabView.swift
//
//
//  Created by harsh vishwakarma on 04/01/24.
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
public struct CalendarTab {
    // MARK: - Inner Reducer for Path
    @Reducer(state: .equatable)
    public enum Path {
        case workout(WorkoutEditor)
        case exerciseLists(ExerciseTemplatesList)
        case exerciseDetails(ExerciseTemplateDetails)
    }
    
    @ObservableState
    public struct State: Equatable {
        var workoutsList = WorkoutsList.State(filter: .none, grouping: true)
        var path = StackState<Path.State>()
        var isWorkoutInProgress = false
    }
    
    public enum Action {
        case path(StackAction<Path.State, Path.Action>)
        
        case showExerciseListButtonTapped
        
        case workoutsList(WorkoutsList.Action)
        
        case delegate(Delegate)
        
        public enum Delegate {
//            case showTabBar(Bool)
            case workoutInProgress(Bool)
            case openWorkout(Workout)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.workoutsList, action: \.workoutsList) {
            WorkoutsList()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate(.workoutInProgress(let value)):
                state.isWorkoutInProgress = value
                return .none
                
            case .delegate:
                return .none
                
                // MARK: - Handling Actions of exerciseLists
                /// Show exercise details
            case let .path(.element(id: _, action: .exerciseLists(.delegate(.showTemplateDetails(template: template))))):
                state.path.append(.exerciseDetails(.init(exercise: template)))
                return .none
                
                /// Handles the action where the user requests to show details of a workout template.
                /// - Parameters:
                ///    - id: The ID of the workout.
                ///    - exerciseID: The ID of the exercise within the workout.
            case let .path(.element(id: id, action: .workout(.exercisesList(.exercises(.element(id: exerciseID, action: .delegate(.showTemplateDetails))))))):
                guard let template = state.path[id: id, case: \.workout]?.exercisesList.exercises[id: exerciseID]?.exercise.template else {return .none}
                state.path.append(.exerciseDetails(.init(exercise: template)))
                return .none
                
                /// Added selected exercises to the current editing Workout   `state.path[id: id, case: \.workout]`
            case let .path(.element(id: _, action: .exerciseLists(.delegate(.didSelectExerciseTemplates(templates))))):
                /// Iterate over all ids and modify the first instance of \.workout
                for (id, element) in zip(state.path.ids, state.path) {
                    if element.is(\.workout) {
                        /// This will trigger existing action ``WorkoutEditor.Action.addSelectedTemplates` in active instance
                        return .send(.path(.element(id: id, action: .workout(.addSelectedTemplates(templates: templates)))))
                    }
                }
                return .none
                /// A call to `popToRoot` exists in ``ExerciseTemplatesList``
            case let .path(.element(id: id, action: .exerciseLists(.delegate(.popToRoot)))):
                return .send(.path(.popFrom(id: id)), animation: .default)
            case .path:
                return .none
                
            case .showExerciseListButtonTapped:
                state.path.append(.exerciseLists(ExerciseTemplatesList.State()))
                return .none
                
            case let .workoutsList(.delegate(.openWorkout(workout))):
                state.path.append(.workout(.init(isWorkoutSaved: true, isWorkoutInProgress: false, workout: workout)))
                return .none
                
            case .workoutsList:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .onChange(of: \.path) { _, newValue in
            Reduce { state, _ in
                // MARK: Show/Hide Tabbar & Change BottomSheet size when we have items in navigation stack
                if state.path.isEmpty {
                    /// Show Bottom TabBar when navigation path is empty
                    return .send(.delegate(.workoutInProgress(false)))
                } else {
                    /// Hide Bottom TabBar when navigation path is not empty
                    return .send(.delegate(.workoutInProgress(true)))
                }
            }
        }
    }
}

struct CalendarTabView: View {
    
    @Environment(\.isPresented) var isPresented
    
    // Keyboard state environment variable
    @Environment(\.keyboardShowing) private var keyboardShowing
    
    @State private var resetScroll: Day? = nil
    @State private var isTodayVisible: Bool = true
    @State private var selectedDateRange: [Day] = getDaysOfCurrentMonth(date: .now)
    @State private var selectedDate: Day = Day(date: .now)
    @State private var today: Day = Day(date: .now)
    
    init(store: StoreOf<CalendarTab>) {
        self.store = store
    }
    
    @Bindable var store: StoreOf<CalendarTab>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path), root: {
            ZStack {
                ScrollViewReader { proxy in
                    ZStack {
                        List {
                            DaySelectView(
                                currentDayRange: $selectedDateRange,
                                scrollTarget: $resetScroll,
                                selectedDate: $selectedDate,
                                isTodayVisible: $isTodayVisible,
                                today: today
                            )
                            .frame(height: 90)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            
                            WorkoutsListView(store: store.scope(state: \.workoutsList, action: \.workoutsList))
                        }
                        .listStyle(.plain)
                        .listSectionSeparator(.hidden)
                        .task {
                            // TODO: find a proper place
                            let (firstDay, lastDay) = getFirstAndLastDayOfMonth(for: Date()) ?? (Date(), Date())
                            store.send(.workoutsList(.setFilter(.dates(date1: firstDay, date2: lastDay))))
                        }
                    }
                    // MARK: Day Select View Bindings
                    .onChange(of: selectedDate) { _, newValue in
                        withEaseOut {
                            proxy.scrollTo(newValue.date.formatted(.dateTime), anchor: .top)
                        }
                        Logger.ui.info("Day Change \(newValue.date.formatted(.dateTime))")
                    }
                }
                .environment(\.defaultMinListRowHeight, 1)
                .safeAreaPadding(.bottom, .customTabBarHeight)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            withCustomSpring {
                                selectedDate -= 1
                                resetScroll = selectedDate
                            }
                        }, label: {
                            Image(systemName: "chevron.left")
                                .symbolEffect(.pulse.byLayer, value: isPresented)
                        })
                        .foregroundStyle(.primary)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text(selectedDate.date, style: .date)
                            .contentTransition(.numericText())
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            withCustomSpring {
                                selectedDate += 1
                                resetScroll = selectedDate
                            }
                        }, label: {
                            Image(systemName: "chevron.right")
                                .symbolEffect(.pulse.byLayer, value: isPresented)
                        })
                        .foregroundStyle(.primary)
                    }
                }
                .toolbarTitleDisplayMode(.inline)
            }
        }, destination: { path in
            // Destination view based on the store's current state
            switch path.case {
            case let .workout(editor):
                WorkoutEditorView(store: editor)
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        VStack(spacing: .defaultVerticalSpacing) {
                            Divider()
                            
                            if editor.isWorkoutInProgress {
                                // Button to show all exercises
                                Button(action: {
                                    store.send(.showExerciseListButtonTapped, animation: .default)
                                }, label: {
                                    Text("Show All Exercises")
                                        .frame(maxWidth: .infinity)
                                })
                                .buttonBorderShape(.capsule)
                                .buttonStyle(.bordered)
                                .foregroundStyle(.primary)
                                .overlay(Capsule().stroke(Color.secondary, lineWidth: 2))
                                .padding(.horizontal, .defaultHorizontalSpacing)
                                
                                HStack {
                                    // Cancel button
                                    Button(role: .destructive, action: {
                                        editor.send(.cancelButtonTapped, animation: .default)
                                    }, label: {
                                        Text("Cancel")
                                            .padding(.horizontal)
                                    })
                                    .foregroundStyle(Color.red)
                                    
                                    // Finish button if exercises are added
                                    Button(action: {
                                        editor.send(.finishButtonTapped, animation: .default)
                                    }, label: {
                                        Text("Save Changes")
                                            .frame(maxWidth: .infinity)
                                    })
                                    .buttonBorderShape(.capsule)
                                    .buttonStyle(.borderedProminent)
                                    .tint(.primary)
                                    .foregroundStyle(.background)
                                }
                                .padding(.horizontal, .defaultHorizontalSpacing)
                            } else {
                                // Button to start or resume workout
                                Button {
                                    // Send a delegate action to edit the workout
                                    editor.send(.startWorkoutButtonTapped, animation: .default)
                                } label: {
                                    Label("Edit Workout", systemImage: "pencil.and.list.clipboard")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonBorderShape(.capsule)
                                .buttonStyle(.bordered)
                                .foregroundStyle(.primary)
                                .overlay(Capsule().stroke(Color.secondary, lineWidth: 2))
                                .padding(.horizontal, .defaultHorizontalSpacing)
                            }
                        }
                        .transition(.identity)
                        .background(.ultraThinMaterial)
                        .foregroundStyle(.primary)
                        .opacity(keyboardShowing ? 0 : 1) // Hide when keyboard is showing
                    }
                    .navigationTitle("\(editor.workout.name.isEmpty ? "Unnamed Workout" : editor.workout.name)")
            case let .exerciseLists(store):
                // ExerciseTemplatesListView when the store's case is .exerciseLists
                ExerciseTemplatesListView(store: store)
            case let .exerciseDetails(store):
                // ExerciseDetailView when the store's case is .exerciseDetails
                ExerciseTemplateDetailView(store: store)
            }
        })
    }
}

#Preview {
    @State var appscreen = AppScreen.logs
    @State var store = StoreOf<TabBarFeature>(initialState: TabBarFeature.State(), reducer: {
        TabBarFeature()
    })
    let container = SwiftDataModelConfigurationProvider.shared.container
    
    return NavigationStack {
        ZStack(alignment: .bottom) {
            CalendarTabView(store: store.scope(state: \.calendar, action: \.calendar))
                .previewBorder()
            CustomTabBar(store: store)
        }
        .modelContainer(container)
    }
}
