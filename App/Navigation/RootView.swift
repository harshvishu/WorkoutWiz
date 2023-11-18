//
//  ContentView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 06/11/23.
//

import SwiftUI
import SwiftData
import DesignSystem
import ApplicationServices
import Persistence
import UI

struct RootView: View {
    
    /// Navigation Properties    
    @Environment(SceneDelegate.self) var sceneDelegate
    
    @Binding var selectedScreen: AppScreen
    @Binding var popToRootScreen: AppScreen
    
    init(selectedScreen: Binding<AppScreen>, popToRootScreen: Binding<AppScreen>) {
        self._selectedScreen = selectedScreen
        self._popToRootScreen = popToRootScreen
    }
    
    var body: some View {
        TabBarView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
            .task {
                guard sceneDelegate.tabWindow == nil else {return}
                sceneDelegate.addTabBar(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
            }
    }
}

fileprivate struct RootView_Previews: PreviewProvider {
    @State static var selectedScreen: AppScreen = .dashboard
    @State static var popToRootScreen: AppScreen = .other
    
    static var previews: some View {
        RootView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
    }
}
