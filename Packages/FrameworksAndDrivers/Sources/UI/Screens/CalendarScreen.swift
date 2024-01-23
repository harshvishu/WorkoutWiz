//
//  CalendarScreen.swift
//  
//
//  Created by harsh vishwakarma on 04/01/24.
//

import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import Domain

@MainActor
public struct CalendarScreen: View {
    @State private var routerPath = RouterPath()
    @Binding var popToRootScreen: AppScreen
    
    init(popToRootScreen: Binding<AppScreen>) {
        _popToRootScreen = popToRootScreen
    }
    
    public var body: some View {
        NavigationStack(path: $routerPath.path) {
            CalendarView()
                .withAppRouter()
                .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
        }
        .environment(routerPath)
    }
}

#Preview {
    @State var popToRootScreen: AppScreen = .other
    
    return DashboardScreen(popToRootScreen: $popToRootScreen)
        .withPreviewEnvironment()
}