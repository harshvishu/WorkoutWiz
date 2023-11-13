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

// MARK: AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseManager.configure()
    return true
  }
}

// MARK: App
@main
struct AppMain: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    logger.log("Welcome to WorkoutWiz!")
                }
        }
    }
}
