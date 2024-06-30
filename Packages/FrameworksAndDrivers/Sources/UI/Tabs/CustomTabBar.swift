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
    
    @Bindable var store: StoreOf<TabBarFeature>
    @Environment(\.keyboardShowing) var isKeyboardShowing
    
    public init(store: StoreOf<TabBarFeature>) {
        self.store = store
    }
    
    public var body: some View {
//        TabView {
//            ForEach(store.state.availableTabs) { tab in
//                Color.clear
//                    .frame(height: 1)
//                    .tabItem {
//                        tab.label
//                    }
//            }
//           
//        }
        
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
            .frame(height: store.showTabBar ? .customTabBarHeight : .zero)
        }
        .background(
            UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: .sheetCornerRadius, bottomLeading: 0, bottomTrailing: 0, topTrailing: .sheetCornerRadius))
                .stroke(.tertiary, lineWidth: 0.5)    // TODO: improve
                .fill(.black)
                .ignoresSafeArea(.all)
                .shadow(color: .secondary.opacity(0.1), radius: 20, x: 0.0, y: 2.0)
        )
        .opacity(store.showTabBar ? 1 : 0)
        .offset(y: store.showTabBar ? .zero : .customTabBarHeight)
        .transition(.slide)
        .animation(.easeInOut, value: store.showTabBar)
        .onChange(of: isKeyboardShowing) { _, visibility in
            store.send(.toggleKeyboardVisiblity(visibility))
        }
        .tag(4)
         
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
