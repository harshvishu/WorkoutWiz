//
//  CustomTabBarView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 18/11/23.
//

import SwiftUI
import DesignSystem

public struct CustomTabBar: View, KeyboardReadable {
    @Environment(AppState.self) var appState
    @Environment(\.keyboardShowing) var keyboardShowing
    
    @Binding var selectedScreen: AppScreen
    @Binding var popToRootScreen: AppScreen
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(AppScreen.availableTabs) { tab in
                    Button( action: {
                        popToRootScreen = .other
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            popToRootScreen = selectedScreen
                        }
                        selectedScreen = tab
                    }, label: {
                        VStack {
                            tab.image
                                .font(.title2)
                            Text(tab.title)
                                .font(.caption)
                        }
                        .foregroundStyle(selectedScreen == tab ? .white : .gray)
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
        .animation(.customSpring(), value: showTabBar)
    }
    
    // Accessor property for showing tab bar
    private var showTabBar: Bool {
        appState.showTabBar && !keyboardShowing
    }
}

#Preview {
    @State var selectedScreen: AppScreen = .dashboard
    @State var popToRootScreen: AppScreen = .other
    
    return CustomTabBar(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .withPreviewEnvironment()
}
