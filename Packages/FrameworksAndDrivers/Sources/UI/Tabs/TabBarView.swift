//
//  TabBarView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 17/11/23.
//

import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import SwiftData
import ComposableArchitecture
import Domain

fileprivate struct Constants {
    static let InitialSheetHeight = CGFloat(110.0)
    static let EligibleBottomSheetScreens: [AppScreen] = [.dashboard]
}

@Reducer
public struct TabBarFeature {
    @ObservableState
    public struct State: Equatable {
        var availableTabs = AppScreen.availableTabs
        var currentTab = AppScreen.dashboard
        var tabBottomSheetDetent = PresentationDetent.InitialSheetDetent
        var showTabBottomSheet = false
        var isBottomSheetResizable = true
        var isKeyboardVisible = false
        var showTabBar = true
        
        // Child States
        var dashboard = DashboardTab.State()
        var workoutEditor = WorkoutEditor.State()
        var settings = Settings.State()
        
        init(availableTabs: [AppScreen] = AppScreen.availableTabs, currentTab: AppScreen = AppScreen.dashboard) {
            self.availableTabs = availableTabs
            self.currentTab = currentTab
            self.showTabBottomSheet = Constants.EligibleBottomSheetScreens.contains(currentTab)
        }
        
        mutating func resetWorkoutEditorState() {
            workoutEditor = WorkoutEditor.State()
        }
    }
    
    public enum Action {
        case dashboard(DashboardTab.Action)
        case settings(Settings.Action)
        
        case selectTab(AppScreen)
        case setBottomSheetPresentationDetent(PresentationDetent)
        
        case toggleKeyboardVisiblity(Bool)
        case toggleBottomSheetResizable(Bool)
        case showTabBottomSheet(Bool)
        case toggleTabBar(Bool)
       
        case workoutEditor(WorkoutEditor.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.dashboard, action: \.dashboard) {
            DashboardTab()
        }
        
        Scope(state: \.settings, action: \.settings) {
            Settings()
        }
        
        Scope(state: \.workoutEditor, action: \.workoutEditor) {
            WorkoutEditor()
        }
        
        Reduce<State,Action> { state, action in
            switch action {
                
                // MARK: - Handle Dashboard Action
            case let .dashboard(.workoutsList(.delegate(delegateAction))):
                switch delegateAction {
                    // Handle tap on workout list
                case let .editWorkout(workout):
                    if !(state.workoutEditor.isWorkoutInProgress && state.workoutEditor.workout.id == workout.id) {
                        state.workoutEditor = WorkoutEditor.State(isWorkoutSaved: true, isWorkoutInProgress: false, workout: workout)
                    }
                    return .send(.setBottomSheetPresentationDetent(.ExpandedSheetDetent), animation: .default)  // expand the bottom sheet
                    // Handle
                case .startNewWorkout:
                    return .send(.setBottomSheetPresentationDetent(.ExpandedSheetDetent), animation: .default)
                case .showCalendarScreen:
                    state.currentTab = .logs
                    return .none
                case .workoutListInvalidated:
                    return .none
                }
                /// When a alert is presented, active bottom sheet hides itself
                /// Present the bottom sheet again
            case .dashboard(.workoutsList(.destination(.presented(.alert)))):
                let show = Constants.EligibleBottomSheetScreens.contains(state.currentTab)
                return .send(.showTabBottomSheet(show), animation: .default)
                
            case .dashboard:
                return .none
                
                // MARK: - Handle Settings Actions
            case .settings:
                return .none
                
                // MARK: - Handle TabBar Actions
            case let .selectTab(tab):
                state.currentTab = tab
                return .send(.setBottomSheetPresentationDetent(.InitialSheetDetent), animation: .customSpring())
          
            case let .setBottomSheetPresentationDetent(detent):
                state.tabBottomSheetDetent = detent
                return .none
                
            case let .showTabBottomSheet(show):
                state.showTabBottomSheet = show
                return .none
                
            case let .toggleKeyboardVisiblity(visibility):
                state.isKeyboardVisible = visibility
                return .none
            case let .toggleBottomSheetResizable(resizable):
                state.isBottomSheetResizable = resizable
                return .none
            case let .toggleTabBar(visibility):
                state.showTabBar = visibility
                return .none
                
                // MARK: WorkoutEditor Action
            case let .workoutEditor(.delegate(delegateAction)):
                switch delegateAction {
                case .collapse:
                    if state.workoutEditor.isWorkoutInProgress.not() {
                        state.resetWorkoutEditorState()
                    }
                    return .send(.setBottomSheetPresentationDetent(.InitialSheetDetent), animation: .default)
                case .expand:
                    return .send(.setBottomSheetPresentationDetent(.ExpandedSheetDetent), animation: .default)
                case .workoutSaved, .workoutDeleted:
                    return .send(.dashboard(.workoutsList(.delegate(.workoutListInvalidated))))
                case .isBottomSheetResizable(let resizable):
                    return .send(.toggleBottomSheetResizable(resizable))
                }
            case .workoutEditor:
                return .none
            }
        }
        .onChange(of: \.currentTab) { _, tab in
            Reduce { state, action in
                let show = Constants.EligibleBottomSheetScreens.contains(tab)
                return .send(.showTabBottomSheet(show), animation: .default)
            }
        }
        .onChange(of: \.tabBottomSheetDetent) { _, detent in
            Reduce { state, _ in
                if detent == .InitialSheetDetent && state.currentTab == .dashboard && state.workoutEditor.isWorkoutInProgress.not() {
                    state.resetWorkoutEditorState()
                }
                
                let showTabBar = detent == .InitialSheetDetent && state.isKeyboardVisible.not() // Hide TabBar when BottomSheet is fully presented && Keyboard is not visible
                return .send(.toggleTabBar(showTabBar), animation: .customSpring())
            }
        }
        .onChange(of: \.isKeyboardVisible, { _, isKeyboardVisible in
            Reduce { state, _ in
                let showTabBar = state.tabBottomSheetDetent == .InitialSheetDetent && isKeyboardVisible.not() // Hide TabBar when BottomSheet is fully presented && Keyboard is not visible
                return .send(.toggleTabBar(showTabBar), animation: .customSpring())
            }
        })
        .onChange(of: \.workoutEditor.workout) { _, workout in
            Reduce { state, _ in
                state.dashboard.workoutsList.activeWorkoutID = workout.id
                return .none
            }
        }
    }
}

public struct TabBarView: View {
    @Bindable var store: StoreOf<TabBarFeature>
    
    public init(store: StoreOf<TabBarFeature>) {
        self.store = store
    }
    
    public var body: some View {
        TabView(selection: .init(get: {
            store.state.currentTab
        }, set: { newTab in
            store.send(.selectTab(newTab))
        }), content:  {
            ForEach(store.availableTabs) { tab in
                tab.makeContentView(store: store)
                    .hideNativeTabBar() /// Hides the native TabBarView we use `CustomTabBar`
                    .tabItem {
                        tab.label
                    }
                    .tag(tab)
            }
        })
        .tabSheet(
            initialHeight: Constants.InitialSheetHeight,
            sheetCornerRadius: .sheetCornerRadius,
            showSheet: $store.showTabBottomSheet.sending(\.showTabBottomSheet),
            resizable: $store.isBottomSheetResizable.sending(\.toggleBottomSheetResizable),
            detents: Self.AvailableSheetDetents,
            selectedDetent: $store.tabBottomSheetDetent.sending(\.setBottomSheetPresentationDetent),
            bottomPadding: store.showTabBar ? .bottomTabSheetCollapsedHeight : .zero,
            content: tabSheetContent
        )
    }
    
    static var AvailableSheetDetents: Set<PresentationDetent> = [.InitialSheetDetent, .ExpandedSheetDetent]
}

fileprivate extension TabBarView {
    
    @ViewBuilder func tabSheetContent() -> some View {
        switch store.currentTab {
        case .dashboard:
            WorkoutEditorBottomSheetView(
                store: store.scope(state: \.workoutEditor, action: \.workoutEditor),
                selectedDetent: $store.tabBottomSheetDetent.sending(\.setBottomSheetPresentationDetent)
            )
        default:
            EmptyView()
        }
    }
}

#Preview {
    @State var store = StoreOf<TabBarFeature>(initialState: TabBarFeature.State(), reducer: {
        TabBarFeature()
    })
    let container = SwiftDataModelConfigurationProvider.shared.container
    
    return TabBarView(store: store)
        .modelContainer(container)
}
