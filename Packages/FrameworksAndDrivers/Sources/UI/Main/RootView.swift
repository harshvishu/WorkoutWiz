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
    
    @State var workoutWizAppModel = WorkoutWizAppModel()
    @State var selectedScreen: AppScreen = .dashboard
    @State var popToRootScreen: AppScreen = .other
    
    @State var recordWorkoutViewModel = RecordWorkoutViewModel()
    
    public var body: some View {
        TabBarView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
            .environment(workoutWizAppModel)
            .environment(recordWorkoutViewModel)
            .task {
                guard sceneDelegate.tabWindow == nil else {return}
                sceneDelegate.addTabBar(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen, workoutWizAppModel: workoutWizAppModel)
            }
    }
}

#Preview {
    return RootView()
        .environment(SceneDelegate())
}
