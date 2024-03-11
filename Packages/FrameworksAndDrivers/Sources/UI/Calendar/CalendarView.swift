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
import ComposableArchitecture

struct CalendarView: View {
    
    @Environment(\.isPresented) var isPresented
    @Environment(\.modelContext) private var modelContext
    
    @State private var resetScroll: Day? = nil
    @State private var isTodayVisible: Bool = true
    @State private var selectedDateRange: [Day] = getCurrentMonthDayRange(date: .now)
    @State private var selectedDate: Day = Day(date: .now)
    @State private var today: Day = Day(date: .now)
    
    // TODO: Pending Move
    let store = StoreOf<WorkoutsListFeature>(initialState: WorkoutsListFeature.State()) {
        WorkoutsListFeature()
    }
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ZStack {
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
                        
                        WorkoutsListView(store: store)
                    }
                    .listStyle(.plain)
                    .listSectionSeparator(.hidden)
                }
                // MARK: Day Select View Bindings
                .onChange(of: selectedDate) { _, newValue in
                    withEaseOut {
                        proxy.scrollTo(newValue.date.formatted(.dateTime), anchor: .top)
                    }
                    Logger.ui.info("Day Change \(newValue.date.formatted(.dateTime))")
                }
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        withCustomSpring {
                            selectedDate -= 1
                            resetScroll = selectedDate
                        }
                    }, label: {
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
                    Button(action: {
                        withCustomSpring {
                            selectedDate += 1
                            resetScroll = selectedDate
                        }
                    }, label: {
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
    NavigationStack {
        CalendarView()
            .previewBorder()
            .withPreviewEnvironment()
    }
}
