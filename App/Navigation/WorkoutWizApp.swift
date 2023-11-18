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
import DesignSystem

let logger: Logger = Logger(subsystem: "com.phychicowl.WorkoutWiz", category: "WorkoutWiz")

// MARK: AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseManager.configure()
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

// MARK: App
@main
struct AppMain: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State var selectedScreen: AppScreen = .dashboard
    @State var popToRootScreen: AppScreen = .other
    
    var body: some Scene {
        WindowGroup {
            RootView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
                .task {
                    logger.log("Welcome to WorkoutWiz!")
                }
        }
    }
}

// MARK: Scene Delegate
@Observable
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    weak var windowScene: UIWindowScene?
    var tabWindow: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        windowScene = scene as? UIWindowScene
    }
    
    func addTabBar(selectedScreen: Binding<AppScreen>, popToRootScreen: Binding<AppScreen>) {
        guard let scene = windowScene else {return}
        
        let tabBarController = UIHostingController(
            rootView: CustomTabBar(selectedScreen: selectedScreen, popToRootScreen: popToRootScreen)
                .frame(maxHeight: .infinity, alignment: .bottom)
        )
        tabBarController.view.backgroundColor = .clear
        
        let tabWindow = PassThroughWindow(windowScene: scene)
        tabWindow.rootViewController = tabBarController
        tabWindow.isHidden = false
        self.tabWindow = tabWindow
    }
}
