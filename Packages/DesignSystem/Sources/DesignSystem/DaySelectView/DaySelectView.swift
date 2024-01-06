//
//  DaySelectView.swift
//  
//
//  Created by harsh on 16/09/22.
//

import SwiftUI

public struct DaySelectView: View {
    @Binding var currentDayRange: [Day]
    @Binding public var scrollTarget: Day?
    @Binding public var selectedDate: Day
    @Binding public var isTodayVisible: Bool
    public var today: Day
    
    public init(
        currentDayRange: Binding<[Day]>,
        scrollTarget: Binding<Day?>,
        selectedDate: Binding<Day>,
        today: Day,
        isTodayVisible: Binding<Bool>
    ) {
        self._currentDayRange = currentDayRange
        self._scrollTarget = scrollTarget
        self._selectedDate = selectedDate
        self.today = today
        self._isTodayVisible = isTodayVisible
    }
    
    public var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ScrollViewReader { (scrollView: ScrollViewProxy) in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(currentDayRange, id: \.self) { day in
                            // MARK: Item
                            DaySelectItemView(viewModel: DaySelectItemViewModel(day: day, isSelected: selectedDate == day), itemSize: getSelectDayItemViewSize(proxy: geometry))
                            //                                .snappingScrollView{$0.scrollSnappingAnchor(.bounds)}
                                .onAppear {
                                    if day == today {
                                        isTodayVisible = true
                                    }
                                }
                                .onDisappear {
                                    if day == today {
                                        isTodayVisible = false
                                    }
                                }
                            
                            // MARK: Day Selection
                                .onTapGesture {
                                    selectedDate = day
                                }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .onAppear {
                    scrollView.scrollTo(today, anchor: .center)
                }
                // MARK: Scroll back to today's date
                .onChange(of: scrollTarget) { _, target in
                    if let target = target {
                        scrollTarget = nil
                        withAnimation {
                            scrollView.scrollTo(target, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}

public struct DaySelectScrollViewContainer: View {
    
    public var viewModel: DaySelectViewModel
    public var itemSize: CGSize
    
    @Binding public var scrollTarget: Day?
    @Binding public var selectedDate: Day
    
    public var body: some View {
        ScrollViewReader { (proxy: ScrollViewProxy) in
            LazyHStack(spacing: 0) {
                ForEach(viewModel.currentDayRange, id: \.self) { day in
                    DaySelectItemView(viewModel: DaySelectItemViewModel(day: day, isSelected: selectedDate == day), itemSize: itemSize)
                    // MARK: Day Selection
                        .onTapGesture {
                            selectedDate = day
                        }
                }
            }
            .onAppear {
                proxy.scrollTo(viewModel.getToday(), anchor: .center)
            }
            // MARK: Scroll back to today's date
            .onChange(of: scrollTarget) { _, target in
                if let target = target {
                    scrollTarget = nil
                    selectedDate = target
                    withAnimation {
                        proxy.scrollTo(target, anchor: .center)
                    }
                }
            }
        }
    }
}

extension DaySelectView {
    private func getSelectDayItemViewSize(proxy: GeometryProxy) -> CGSize {
        return CGSize(width: (proxy.size.width / CGFloat(7)) - 10, height: 90)
    }
}

public func getCurrentMonthDayRange(date: Date) -> [Day] {
    let calendar = Calendar.current
    let month = calendar.dateInterval(of: .month, for: date)
    
    guard let firstMonthDay = month?.start else {return []}
    guard let numberOfDays = calendar.range(of: .day, in: .month, for: date)?.count else {return []}
    
    return (0..<numberOfDays).compactMap{Day(date: calendar.date(byAdding: .day, value: $0, to: firstMonthDay))}
}

public func getNextMonthDayRangeByAdding(count: Int, toDate date: Date) -> [Day] {
    let calendar = Calendar.current
    guard let date = calendar.date(byAdding: .month, value: count, to: date) else {return []}
    let month = calendar.dateInterval(of: .month, for: date)
    
    guard let firstMonthDay = month?.start else {return []}
    guard let numberOfDays = calendar.range(of: .day, in: .month, for: date)?.count else {return []}
    
    return (0..<numberOfDays).compactMap{Day(date: calendar.date(byAdding: .day, value: $0, to: firstMonthDay))}
}


#Preview {
    ZStack {
        DaySelectView(
            currentDayRange: .constant([Day(date: Date().addingTimeInterval(-900000)),
                                        Day(date: Date().addingTimeInterval(-890000)),
                                        Day(date: Date().addingTimeInterval(-800000)),
                                        Day(date: Date().addingTimeInterval(-700000)),
                                        Day(date: Date().addingTimeInterval(-600000)),
                                        Day(date: Date().addingTimeInterval(-500000)),
                                        Day(date: Date().addingTimeInterval(-400000)),
                                        Day(date: Date().addingTimeInterval(-300000)),
                                        Day(date: Date().addingTimeInterval(-250000)),
                                        Day(date: Date().addingTimeInterval(-200000)),
                                       ]),
            scrollTarget: .constant(Day(date: Date().addingTimeInterval(-700000))),
            selectedDate: .constant(Day(date: Date().addingTimeInterval(-700000))),
            today: Day(date: Date()),
            isTodayVisible: .constant(true)
        )
        .padding()
    }
    .previewBackground()
}
