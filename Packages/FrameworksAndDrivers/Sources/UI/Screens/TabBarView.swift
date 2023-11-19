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
    @State private var showSheet = false
    
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
        .tabSheet(initialHeight: 116.0, sheetCornerRadius: 15.0, showSheet: $showSheet) {
            // TODO: Make it dynamic
            NavigationStack {
                ScrollView {
                    
                }
                .scrollIndicators(.hidden)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Text(selectedScreen.title)
                            .font(.title3.bold())
                    }
                    
                    if selectedScreen == .dashboard {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                RecordWorkoutView()
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                })
            }
        }
        .onChange(of: selectedScreen, { _, newValue in
            showSheet = newValue == .dashboard
        })
        .onAppear {
            let tempScreen = selectedScreen
            selectedScreen = AppScreen.other
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                selectedScreen = tempScreen
            }
        }
    }
}

#Preview {
    @State var selectedScreen: AppScreen = .dashboard
    @State var popToRootScreen: AppScreen = .other
    
    return TabBarView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
}
