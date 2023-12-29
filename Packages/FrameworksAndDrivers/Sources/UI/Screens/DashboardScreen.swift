//
//  DashboardTab.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 17/11/23.
//

import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import Domain

@MainActor
public struct DashboardScreen: View {
    @State private var routerPath = RouterPath()
    @Binding var popToRootScreen: AppScreen
    
    init(popToRootScreen: Binding<AppScreen>) {
        _popToRootScreen = popToRootScreen
    }
    
    public var body: some View {
        NavigationStack(path: $routerPath.path) {
            DashboardView()
                .withAppRouter()
                .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
                .environment(routerPath)
        }
    }
}

#Preview {
    @State var popToRootScreen: AppScreen = .other
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return DashboardScreen(popToRootScreen: $popToRootScreen)
        .environment(globalMessageQueue)
}
