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
        ZStack {
            ScrollViewReader { proxy in
                ZStack(alignment: .top) {
                    List {
                        DaySelectView(
                            currentDayRange: $selectedDateRange,
                            scrollTarget: $resetScroll,
                            selectedDate: $selectedDate,
                            isTodayVisible: $isTodayVisible, 
                            today: today
                        )
                        .frame(height: 90)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        
                        ListWorkoutView(filter: .none, grouping: true)
                    }
                }
                // MARK: Day Select View Bindings
                .onChange(of: selectedDate) { _, newValue in
                    withEaseOut {
                        proxy.scrollTo(newValue.date.formatted(.dateTime), anchor: .top)
                    }
                    logger.info("Day Change \(newValue.date.formatted(.dateTime))")
                }
            }
            .safeAreaInset(edge: .bottom, content: {
                EmptyView()
                    .frame(height: .bottomListPadding)
            })
            .listStyle(.plain)
            .listSectionSeparator(.hidden)
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {}, label: {
                        Image(systemName: "chevron.left")
                            .symbolEffect(.pulse.byLayer, value: isPresented)
                    })
                    .foregroundStyle(.primary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text(selectedDate.date, style: .date)
                        .contentTransition(.numericText())
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}, label: {
                        Image(systemName: "chevron.right")
                            .symbolEffect(.pulse.byLayer, value: isPresented)
                    })
                    .foregroundStyle(.primary)
                }
            }
            .toolbarTitleDisplayMode(.inline)
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
