//
//  WorkoutWizApp.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 06/11/23.
//

import SwiftUI
import OSLog
import UI
import Persistence

let logger: Logger = Logger(subsystem: "com.phychicowl.WorkoutWiz", category: "WorkoutWiz")

@main
struct AppMain: App {
    init() {
        FirebaseManager.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    logger.log("Welcome to WorkoutWiz!")
                }
        }
    }
}
