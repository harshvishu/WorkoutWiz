//
//  File.swift
//
//
//  Created by harsh vishwakarma on 17/11/23.
//

import Foundation
import SwiftUI

/// Screens
public enum AppScreen: Hashable, Identifiable , CaseIterable {
    
    nonisolated
    public var id: AppScreen { self }
    
    case dashboard
    case profile
    case logs
    case settings
    case other
    
    /// Available Tabs for
    static var availableTabs: [AppScreen] {
        [.dashboard, .profile, .logs, .settings]
    }
    
    var systemImageName: String {
        switch self {
        case .dashboard:
            "square.grid.2x2.fill"
        case .profile:
            "person.circle.fill"
        case .logs:
            "calendar"
        case .settings:
            "gearshape.fill"
        case .other:
            ""
        }
    }
    
    public var title: String {
        switch self {
        case .dashboard:
            "Dashboard"
        case .profile:
            "Profile"
        case .logs:
            "Logs"
        case .settings:
            "Settings"
        case .other:
            ""
        }
    }
    
    @ViewBuilder
    var label: some View {
        Label(title, systemImage: systemImageName)
    }
    
    @ViewBuilder
    var image: some View {
        Image(systemName: systemImageName)
    }
    
    @ViewBuilder
    @MainActor
    func makeContentView(popToRootScreen: Binding<AppScreen>) -> some View {
        switch self {
        case .dashboard:
            DashboardScreen(popToRootScreen: popToRootScreen)
        case .profile:
            Text("Profile")
        case .logs:
            Text("Calendar")
        case .settings:
            Text("Settings")
        case .other:
            EmptyView()
        }
    }
}
