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
    @Environment(ConcreteMessageQueue<ApplicationMessage>.self) private var globalMessageQueue
    
    
    var body: some View {
        VStack {
            HStack {
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
                Spacer()
                Image(systemName: "bell.badge.fill")
                    .symbolEffect(.pulse.byLayer, value: isPresented)
            }
            .padding(.horizontal)
            
            ScrollViewReader { proxy in
                ZStack(alignment: .top) {
                    List {
                        ListWorkoutView()
                    }
                }
            }
            .listStyle(.plain)
            .listSectionSeparator(.hidden)
            .scrollContentBackground(.hidden)
            .onChange(of: isPresented) { _, isPresented in
                //            if !isPresented {
                //                viewModel.didSelect(exercises: getSelectedExercises())
                //            }
            }
        }
    }
}

#Preview {
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return DashboardView()
        .previewBorder()
        .environment(globalMessageQueue)
        .withPreviewModelContainer()
    
}

