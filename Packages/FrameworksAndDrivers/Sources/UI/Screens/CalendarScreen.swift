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
    
    public var body: some View {
        NavigationStack {
            CalendarView()
                .withAppRouter()
                .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
        }
        .environment(routerPath)
    }
}

//#Preview {
//    @State var popToRootScreen: AppScreen = .other
//    
//    return DashboardScreen()
//        .withPreviewEnvironment()
//}
