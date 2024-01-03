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
    @Environment(\.modelContext) private var modelContext
    
    @State private var workoutWizAppModel = WorkoutWizAppModel()
    @State private var saveDataManager = SaveDataManager(saveDataUseCase: nil)
    /// Application Wide Message Queue
    @State private var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    @State var selectedScreen: AppScreen = .dashboard
    @State var popToRootScreen: AppScreen = .other
    
    public var body: some View {
        TabBarView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
            .environment(workoutWizAppModel)
            .environment(saveDataManager)
            .environment(globalMessageQueue)
            .onReceive(globalMessageQueue.signal) { newValue in
                if case .showLogs = newValue {
                    withCustomSpring {
                        selectedScreen = .logs
                    }
                }
            }
            .task {
                initializeSwiftDataManager()
                initializeTabBar()
            }
    }
}

extension RootView {
    fileprivate func initializeSwiftDataManager() {
        if saveDataManager.saveDataUseCase == nil {
            saveDataManager.saveDataUseCase = SaveDataUseCase(saveDataRepository: SwiftDataSaveDataRepository(modelContext: modelContext))
        }
    }
    
    fileprivate func initializeTabBar() {
        guard sceneDelegate.tabWindow == nil else {return}
        sceneDelegate.addTabBar(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen, workoutWizAppModel: workoutWizAppModel)
    }
}

#Preview {
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return RootView()
        .environment(globalMessageQueue)
        .environment(SceneDelegate())
}
