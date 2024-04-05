//
//  WorkoutWizApp.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 06/11/23.
//

import SwiftUI
import UI
import ComposableArchitecture

/// The entry point to the app simply loads the App implementation from SPM module (UI).
@main struct AppMain: WorkoutWizApp {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()._printChanges()
    }
}
