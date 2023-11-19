//
//  File.swift
//  
//
//  Created by harsh vishwakarma on 19/11/23.
//

import SwiftUI
import OSLog
import Persistence
import DesignSystem

let logger: Logger = Logger(subsystem: "com.phychicowl.WorkoutWiz", category: "WorkoutWiz")

public protocol WorkoutWizApp : App {}

/// The entry point to the WorkoutWiz app.
/// The concrete implementation is in the WorkoutWizApp parent app.
public extension WorkoutWizApp {
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {logger.log("Welcome to WorkoutWiz!")}
        }
    }
}
