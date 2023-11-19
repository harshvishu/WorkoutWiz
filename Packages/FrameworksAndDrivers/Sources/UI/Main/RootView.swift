//
//  ContentView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 06/11/23.
//

import SwiftUI

public struct RootView: View {
    
    /// Navigation Properties    
    @Environment(SceneDelegate.self) var sceneDelegate
    
    @State var selectedScreen: AppScreen = .dashboard
    @State var popToRootScreen: AppScreen = .other
    
//    public init(selectedScreen: Binding<AppScreen>, popToRootScreen: Binding<AppScreen>) {
//        self._selectedScreen = selectedScreen
//        self._popToRootScreen = popToRootScreen
//    }
    
    public var body: some View {
        TabBarView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
            .task {
                guard sceneDelegate.tabWindow == nil else {return}
                sceneDelegate.addTabBar(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
            }
    }
}

#Preview {
    return RootView()
        .environment(SceneDelegate())
}
