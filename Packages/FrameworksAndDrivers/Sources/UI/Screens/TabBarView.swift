//
//  TabBarView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 17/11/23.
//

import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence

fileprivate struct Constants {
    static let InitialSheetHeight = CGFloat(116.0)
    static let EligibleBottomSheetScreens: [AppScreen] = [.dashboard]
}

@MainActor
public struct TabBarView: View {
    
    /// navigation properties
    @Binding var selectedScreen: AppScreen
    @Binding var popToRootScreen: AppScreen
    
    public init(selectedScreen: Binding<AppScreen>, popToRootScreen: Binding<AppScreen>) {
        _selectedScreen = selectedScreen
        _popToRootScreen = popToRootScreen
    }
    
    /// view properties
    @State private var showTabBottomSheet = false
    @State var selectedDetent: PresentationDetent = .InitialSheetDetent
    
    /// internal properties
    private var availableSheetDetents: Set<PresentationDetent> = [.InitialSheetDetent, .ExpandedSheetDetent]
    
    public var body: some View {
        TabView(selection: .init(get: {
            selectedScreen
        }, set: { newTab in
            /// Stupid hack to trigger onChange binding in tab views.
            popToRootScreen = .other
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                popToRootScreen = selectedScreen
            }
            selectedScreen = newTab
        }), content:  {
            ForEach(AppScreen.availableTabs) { tab in
                tab.makeContentView(popToRootScreen: $popToRootScreen)
                    .hideNativeTabBar() /// Hides the native TabBarView we use `CustomTabBar`
                    .tabItem {
                        tab.label
                    }
                    .tag(tab)
            }
        })
        .tabSheet(initialHeight: Constants.InitialSheetHeight, sheetCornerRadius: 15.0, showSheet: $showTabBottomSheet, detents: availableSheetDetents, selectedDetent: $selectedDetent, content: tabSheetContent)
        .onChange(of: selectedScreen, initial: true, { _, newValue in
            /// Make it more dynamic
            showTabBottomSheet = Constants.EligibleBottomSheetScreens.contains(newValue)
            /// Reset `selectedDetent` on change of screen
            selectedDetent = .InitialSheetDetent
        })
//        .onAppear {
//            let tempScreen = selectedScreen
//            selectedScreen = AppScreen.other
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                selectedScreen = tempScreen
//            }
//        }
    }
}

fileprivate extension TabBarView {
    
    @ViewBuilder func tabSheetContent() -> some View {
        switch selectedScreen {
        case .dashboard:
            RecordWorkoutView(selectedDetent: $selectedDetent)
        default:
            EmptyView()
        }
    }
}

#Preview {
    @State var selectedScreen: AppScreen = .dashboard
    @State var popToRootScreen: AppScreen = .other
    
    return TabBarView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
}
