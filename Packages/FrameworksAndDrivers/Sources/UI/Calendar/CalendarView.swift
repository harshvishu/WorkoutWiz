//
//  CalendarView.swift
//  
//
//  Created by harsh vishwakarma on 04/01/24.
//

import SwiftUI
import Domain
import ApplicationServices
import Persistence
import DesignSystem
import OSLog
import SwiftData

struct CalendarView: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: CalendarView.self))
    
    @Environment(\.isPresented) var isPresented
    @Environment(\.modelContext) private var modelContext
    @Environment(ConcreteMessageQueue<ApplicationMessage>.self) private var globalMessageQueue
    
    @State private var resetScroll: Day? = nil
    @State private var isTodayVisible: Bool = true
    @State private var selectedDateRange: [Day] = getCurrentMonthDayRange(date: .now)
    @State private var selectedDate: Day = Day(date: .now)
    @State private var today: Day = Day(date: .now)
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ZStack(alignment: .top) {
                    List {
                        DaySelectView(
                            currentDayRange: $selectedDateRange,
                            scrollTarget: $resetScroll,
                            selectedDate: $selectedDate,
                            today: today,
                            isTodayVisible: $isTodayVisible
                        )
                        .frame(height: 90)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        
                        ListWorkoutView(filter: .none)
                    }
                }
            }
            .safeAreaInset(edge: .bottom, content: {
                EmptyView()
                    .frame(height: 110)
            })
            .listStyle(.plain)
            .listSectionSeparator(.hidden)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.left")
                        .symbolEffect(.pulse.byLayer, value: isPresented)
                }
                
                
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "chevron.right")
                        .symbolEffect(.pulse.byLayer, value: isPresented)
                }
            }
            .onChange(of: isPresented) { _, isPresented in
            }
        }
    }
}

#Preview {
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return NavigationStack {
        CalendarView()
            .previewBorder()
            .environment(globalMessageQueue)
            .withPreviewModelContainer()
    }
}
