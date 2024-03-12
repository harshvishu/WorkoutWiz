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
import ComposableArchitecture

public struct RootView: View {
    
    /// Navigation Properties    
    @Environment(SceneDelegate.self) var sceneDelegate
    
    @Bindable var store: StoreOf<TabBarFeature>
    
    public var body: some View {
        TabBarView(store: store)
            .task {
                initializeCustomTabBar()
                initializePopupContainer()
            }
    }
}

extension RootView {
    fileprivate func initializeCustomTabBar() {
        guard sceneDelegate.tabWindow == nil else {return}
        sceneDelegate.addTabBar(store: store)
    }
    
    fileprivate func initializePopupContainer() {
        guard sceneDelegate.popWindow == nil else {return}
        sceneDelegate.addPopupContainerView()
    }
}

#Preview {
    return RootView(store: StoreOf<TabBarFeature>(initialState: TabBarFeature.State(), reducer: {
        TabBarFeature()
    }))
    .withPreviewEnvironment()
}
