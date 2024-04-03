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

// TODO: Move implementation to CalendarTab (Create new)

@MainActor
public struct CalendarScreen: View {
    
    public var body: some View {
        NavigationStack {
            CalendarView()
                .hideNativeTabBar()
        }
    }
}
