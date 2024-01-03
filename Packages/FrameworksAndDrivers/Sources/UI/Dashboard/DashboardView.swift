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
                        
                        ListWorkoutView()
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
                        .foregroundStyle(Color.accentColor, Color.primary)
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
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return NavigationStack {
        DashboardView()
            .previewBorder()
            .environment(globalMessageQueue)
            .withPreviewModelContainer()
    }
}


func getCurrentMonthDayRange(date: Date) -> [Day] {
    let calendar = Calendar.current
    let month = calendar.dateInterval(of: .month, for: date)
    
    guard let firstMonthDay = month?.start else {return []}
    guard let numberOfDays = calendar.range(of: .day, in: .month, for: date)?.count else {return []}
    
    return (0..<numberOfDays).compactMap{Day(date: calendar.date(byAdding: .day, value: $0, to: firstMonthDay))}
}

func getNextMonthDayRangeByAdding(count: Int, toDate date: Date) -> [Day] {
    let calendar = Calendar.current
    guard let date = calendar.date(byAdding: .month, value: count, to: date) else {return []}
    let month = calendar.dateInterval(of: .month, for: date)
    
    guard let firstMonthDay = month?.start else {return []}
    guard let numberOfDays = calendar.range(of: .day, in: .month, for: date)?.count else {return []}
    
    return (0..<numberOfDays).compactMap{Day(date: calendar.date(byAdding: .day, value: $0, to: firstMonthDay))}
}
