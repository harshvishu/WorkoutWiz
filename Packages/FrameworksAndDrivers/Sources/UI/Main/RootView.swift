//
//  ContentView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 06/11/23.
//

import SwiftUI
import Persistence
import ApplicationServices
import DesignSystem

public struct RootView: View {
    
    /// Navigation Properties    
    @Environment(SceneDelegate.self) var sceneDelegate
    @Environment(AppState.self) var appState
    
    @State var selectedScreen: AppScreen = .dashboard
    @State var popToRootScreen: AppScreen = .other
    
    public var body: some View {
        TabBarView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
            .onReceive(appState.signal) { newValue in
                if case .showLogs = newValue {
                    withCustomSpring {
                        selectedScreen = .logs
                    }
                }
            }
            .task {
                initializeCustomTabBar()
                initializePopupContainer()
            }
    }
}

extension RootView {
    fileprivate func initializeCustomTabBar() {
        guard sceneDelegate.tabWindow == nil else {return}
        sceneDelegate.addTabBar(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen, appState: appState)
    }
    
    fileprivate func initializePopupContainer() {
        guard sceneDelegate.popWindow == nil else {return}
        sceneDelegate.addPopupContainerView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen, appState: appState)
    }
}

#Preview {
    return RootView()
        .withPreviewEnvironment()
}
