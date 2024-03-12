//
//  CustomTabBarView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 18/11/23.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

public struct CustomTabBar: View, KeyboardReadable {
    @Environment(\.keyboardShowing) var keyboardShowing
    
    @Bindable var store: StoreOf<TabBarFeature>
    @Dependency(\.keyboardShowing.isKeyboardShowing) var isKeyboardShowing
    
    public init(store: StoreOf<TabBarFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(store.state.availableTabs) { tab in
                    Button( action: {
                        store.send(.selectTab(tab))
                    }, label: {
                        VStack {
                            tab.image
                                .font(.title2)
                            Text(tab.title)
                                .font(.caption)
                        }
                        .foregroundStyle(store.state.currentTab == tab ? .white : .gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(.rect)
                    })
                }
            }
            .frame(height: showTabBar ? .customTabBarHeight : .zero)
        }
        .background(
            UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: .sheetCornerRadius, bottomLeading: 0, bottomTrailing: 0, topTrailing: .sheetCornerRadius))
                .stroke(.tertiary, lineWidth: 1)    // TODO: improve
                .fill(.black)
                .ignoresSafeArea(.all)
                .shadow(color: .secondary.opacity(0.1), radius: 20, x: 0.0, y: 2.0)
        )
        .opacity(showTabBar ? 1 : 0)
        .offset(y: showTabBar ? .zero : .customTabBarHeight)
        .transition(.slide)
        .animation(.easeInOut, value: showTabBar)
        .onChange(of: keyboardShowing) { _, visibility in
            store.send(.toggleKeyboardVisiblity(visibility))
        }
    }
    
    // Accessor property for showing tab bar
    private var showTabBar: Bool {
        // TODO:
        /*store.showTabBar &&*/ isKeyboardShowing.not()
    }
}

//#Preview {
//    @State var selectedScreen: AppScreen = .dashboard
//    @State var popToRootScreen: AppScreen = .other
//    
//    return CustomTabBar(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
//        .frame(maxHeight: .infinity, alignment: .bottom)
//        .withPreviewEnvironment()
//}
