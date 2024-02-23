//
//  File.swift
//
//
//  Created by harsh vishwakarma on 19/11/23.
//

import UIKit
import SwiftUI
import DesignSystem

// MARK: Scene Delegate
@Observable
public final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    public weak var windowScene: UIWindowScene?
    public var tabWindow: UIWindow?
    public var popWindow: UIWindow?
    
    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        windowScene = scene as? UIWindowScene
    }
    
    public func addTabBar(
        selectedScreen: Binding<AppScreen>,
        popToRootScreen: Binding<AppScreen>,
        appState: AppState
    ) {
        guard let scene = windowScene else {return}
        
        let tabBarController = UIHostingController(
            rootView:
                CustomTabBar(selectedScreen: selectedScreen, popToRootScreen: popToRootScreen)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .environment(appState)
                .addKeyboardVisibilityToEnvironment()
        )
        tabBarController.view.backgroundColor = .clear
        
        let tabWindow = PassThroughWindow(windowScene: scene)
        tabWindow.rootViewController = tabBarController
        tabWindow.isHidden = false
        self.tabWindow = tabWindow
    }   
    
    public func addPopupContainerView(
        selectedScreen: Binding<AppScreen>,
        popToRootScreen: Binding<AppScreen>,
        appState: AppState
    ) {
        guard let scene = windowScene else {return}
        
        let popupContainerController = UIHostingController(
            rootView:
                PopupPresenterView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environment(appState)
                .addKeyboardVisibilityToEnvironment()
        )
        popupContainerController.view.backgroundColor = .clear
        
        let window = PassThroughWindow(windowScene: scene)
        window.rootViewController = popupContainerController
        window.isHidden = false
        self.popWindow = window
    }
}
