//
//  File.swift
//  
//
//  Created by harsh vishwakarma on 19/11/23.
//

import SwiftUI
import Persistence

// MARK: AppDelegate
public class AppDelegate: NSObject, UIApplicationDelegate {
    public func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseManager.configure()
        return true
    }
    
    public func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
