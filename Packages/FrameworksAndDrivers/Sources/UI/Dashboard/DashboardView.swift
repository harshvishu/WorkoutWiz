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
    
    @State private var resetScroll: Day? = nil
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ZStack(alignment: .top) {
                    List {
                        ListWorkoutView(filter: .date(.now), grouping: false)
                    }
                }
            }
            .safeAreaInset(edge: .bottom, content: {
                EmptyView()
                    .frame(height: .customTabBarHeight)
            })
            .listStyle(.plain)
            .listSectionSeparator(.hidden)
            .scrollIndicators(.hidden)
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
            .onChange(of: isPresented) { _, isPresented in
                //            if !isPresented {
                //                viewModel.didSelect(exercises: getSelectedExercises())
                //            }
            }
        }
    }
}

#Preview {
    return NavigationStack {
        DashboardView()
            .previewBorder()
            .withPreviewEnvironment()
    }
}
