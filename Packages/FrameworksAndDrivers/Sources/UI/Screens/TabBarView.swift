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
        var bottomSheetPresentationDetent = PresentationDetent.InitialSheetDetent
        var showTabBottomSheet = false
        var resizable = true
        var isKeyboardVisible = false
        
        // Child States
        var dashboard = DashboardTab.State()
        var workoutEditor = WorkoutEditorFeature.State()
        
        init(availableTabs: [AppScreen] = AppScreen.availableTabs, currentTab: AppScreen = AppScreen.dashboard) {
            self.availableTabs = availableTabs
            self.currentTab = currentTab
            self.showTabBottomSheet = Constants.EligibleBottomSheetScreens.contains(currentTab)
        }
    }
    
    public enum Action {
        case selectTab(AppScreen)
        case toggleTabBottomSheet(Bool)
        case setBottomSheetPresentationDetent(PresentationDetent)
        case toggleKeyboardVisiblity(Bool)
        case toggleResizable(Bool)
        case delegate(Delegate)
        case dashboard(DashboardTab.Action)
        case workoutEditor(WorkoutEditorFeature.Action)
        
        @CasePathable
        public enum Delegate {
          case showLogs
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.dashboard, action: \.dashboard) {
            DashboardTab()
        }
        
        Scope(state: \.workoutEditor, action: \.workoutEditor) {
            WorkoutEditorFeature()
        }
        
        Reduce<State,Action> { state, action in
            switch action {
            case let .selectTab(tab):
                state.currentTab = tab
                return .send(.setBottomSheetPresentationDetent(.InitialSheetDetent), animation: .customSpring())
            case let .toggleTabBottomSheet(show):
                state.showTabBottomSheet = show
                return .none
            case let .setBottomSheetPresentationDetent(detent):
                state.bottomSheetPresentationDetent = detent
                return .none
            case let .toggleKeyboardVisiblity(visibility):
                state.isKeyboardVisible = visibility
                return .none
            case let .toggleResizable(resizable):
                state.resizable = resizable
                return .none
            case .delegate:
                return .none
                
            case let .dashboard(.dashboard(.workoutsList(.delegate(.editWorkout(workout))))):
                guard state.workoutEditor.isWorkoutInProgress.not() else {return .none}
                state.workoutEditor = WorkoutEditorFeature.State(isWorkoutSaved: true, isWorkoutInProgress: true, workout: workout)
                state.bottomSheetPresentationDetent = .ExpandedSheetDetent
                return .none
            case .dashboard:
                return .none
            case let .workoutEditor(.delegate(delegateAction)):
                switch delegateAction {
                case .collapse:
                    return .send(.setBottomSheetPresentationDetent(.InitialSheetDetent), animation: .default)
                case .expand:
                    return .send(.setBottomSheetPresentationDetent(.ExpandedSheetDetent), animation: .default)
                case .workoutSaved:
                    return .send(.dashboard(.dashboard(.workoutsList(.fetchWorkouts))))
                case .navigationStackNonEmpty:
                    state.resizable = false
                    return .none
                case .navigationStackIsEmpty:
                    state.resizable = true
                    return .none
                }
            case .workoutEditor:
                // TODO: handle workout editor
                return .none
            }
        }
        .onChange(of: \.currentTab) { _, tab in
            Reduce { state, action in
                state.showTabBottomSheet = Constants.EligibleBottomSheetScreens.contains(tab)
                return .none
            }
        }
        .onChange(of: \.bottomSheetPresentationDetent) { _, detent in
            Reduce { state, action in
                // TODO:
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
        .tabSheet(initialHeight: Constants.InitialSheetHeight, sheetCornerRadius: .sheetCornerRadius, showSheet: $store.showTabBottomSheet.sending(\.toggleTabBottomSheet), resizable: $store.resizable.sending(\.toggleResizable), detents: Self.AvailableSheetDetents, selectedDetent: $store.bottomSheetPresentationDetent.sending(\.setBottomSheetPresentationDetent), bottomPadding: .customTabBarHeight, content: tabSheetContent)
    }
    
    static var AvailableSheetDetents: Set<PresentationDetent> = [.InitialSheetDetent, .ExpandedSheetDetent]
}

fileprivate extension TabBarView {
    
    @ViewBuilder func tabSheetContent() -> some View {
        switch store.currentTab {
        case .dashboard:
            WorkoutEditorBottomSheetView(
                store: store.scope(state: \.workoutEditor, action: \.workoutEditor),
                selectedDetent: $store.bottomSheetPresentationDetent.sending(\.setBottomSheetPresentationDetent)
            )
        default:
            EmptyView()
        }
    }
}

//#Preview {
//    @State var selectedScreen: AppScreen = .dashboard
//    @State var popToRootScreen: AppScreen = .other
//    
//    return TabBarView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
//        .withPreviewEnvironment()
//}
