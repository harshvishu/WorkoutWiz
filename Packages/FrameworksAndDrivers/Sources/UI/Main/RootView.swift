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
        ZStack(alignment: .bottom) {
            TabBarView(store: tabBarStore)
                .frame(maxHeight: .infinity)
            CustomTabBar(store: tabBarStore)
                .frame(alignment: .bottom)
        }
        .task {
            initializePopupContainer()
        }
    }
}

extension RootView {
    @available(*, deprecated, message: "Not using `initializeCustomTabBar()` since it is not working on ios18.")
    fileprivate func initializeCustomTabBar() {
        guard sceneDelegate.tabWindow == nil else {return}
        sceneDelegate.addTabBar(store: tabBarStore)
    }
    
    /// - Warning: Window does not respond to touch events unless it as alert level. So, only default sheets, alerts are working. Needs potential replacement like `initializeCustomTabBar()`
    @available(*, message: "Window does not respond to touch events unless it as alert level. So, only default sheets, alerts are working")
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
