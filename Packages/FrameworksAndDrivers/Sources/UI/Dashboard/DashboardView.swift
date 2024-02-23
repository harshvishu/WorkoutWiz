//
//  DashboardView.swift
//
//
//  Created by harsh vishwakarma on 29/12/23.
//

import SwiftUI
import Domain
import ApplicationServices
import Persistence
import DesignSystem
import OSLog
import SwiftData

struct DashboardView: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: DashboardView.self))
    
    @Environment(\.isPresented) var isPresented
    @Environment(\.modelContext) private var modelContext
    
    @Environment(AppState.self) private var appState
    @Environment(RouterPath.self) private var routerPath
    
    @State private var resetScroll: Day? = nil

    var body: some View {
        ZStack {
            // Main Scroll View
            ScrollViewReader { proxy in
                ZStack(alignment: .bottomTrailing) {
                    List {
                        ListWorkoutView(filter: .date(.now), grouping: false)
                            .scrollContentBackground(.hidden)
                    }
//                    Button(action: {
//                        routerPath.navigate(to: .newWorkout)
//                    }, label: {
//                        Image(systemName: "plus")
//                            .foregroundStyle(.secondary)
////                            .rotationEffect(Angle(degrees: selectedDetent.isCollapsed ? 0 : 360 + 45))
//                    })
//                    .font(.title)
//                    .foregroundStyle(.primary)
//                    .buttonStyle(.bordered)
//                    .buttonBorderShape(.circle)
//                    .padding([.trailing, .bottom])
                }
            }
            .safeAreaInset(edge: .bottom, content: {
                EmptyView()
                    .frame(height: 0)
//                    .frame(height: .customTabBarHeight)
            })
            .listStyle(.plain)
            .listSectionSeparator(.hidden)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Image(.equipment4)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 42, height: 42)
                        .clipShape(Circle())

                    VStack {
                        Text("Hi, Harsh")
                            .font(.title3.bold())
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Image(systemName: "bell.badge.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.accentColor, Color.primary.opacity(0.64))
                        .symbolEffect(.pulse.byLayer, value: isPresented)
                }
            }
        }
    }
}

#Preview {
    @State var appscreen = AppScreen.dashboard
    
    return NavigationStack {
        ZStack(alignment: .bottom) {
            DashboardView()
                .previewBorder()
            CustomTabBar(selectedScreen: $appscreen, popToRootScreen: $appscreen)
        }
        .withPreviewEnvironment()
    }
}
