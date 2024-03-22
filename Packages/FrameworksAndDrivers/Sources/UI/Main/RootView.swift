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
    
    @Bindable var tabBarStore: StoreOf<TabBarFeature>
    @Bindable var popupStore: StoreOf<PopupPresenter>
    
    public var body: some View {
        TabBarView(store: tabBarStore)
            .task {
                initializeCustomTabBar()
                initializePopupContainer()
            }
    }
}

extension RootView {
    fileprivate func initializeCustomTabBar() {
        guard sceneDelegate.tabWindow == nil else {return}
        sceneDelegate.addTabBar(store: tabBarStore)
    }
    
    fileprivate func initializePopupContainer() {
        guard sceneDelegate.popWindow == nil else {return}
        sceneDelegate.addPopupContainerView(store: popupStore)
    }
}

#Preview {
    return RootView(tabBarStore: StoreOf<TabBarFeature>(initialState: TabBarFeature.State(), reducer: {
        TabBarFeature()
    }), popupStore: StoreOf<PopupPresenter>(initialState: PopupPresenter.State(), reducer: {
        PopupPresenter()
    }))
    .withPreviewEnvironment()
}
