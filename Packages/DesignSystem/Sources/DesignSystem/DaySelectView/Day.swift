//
//  Day.swift
//  
//
//  Created by harsh on 17/09/22.
//

import Foundation

private let DayFormat = "dd"
private let MonthFormat = "MM"
private let YearFormat = "yyyy"
private let DayMonthYearFormat = "dd/MM/yyyy"

public struct Day: Identifiable, Codable {
    public var id: UUID = UUID()
    public let day: Int
    public let month: Int
    public let year: Int
    public let date: Date
    
    public init(date: Date) {
        self.date = date
        let formatter = DateFormatter()
        // Day
        day = Int(extractDate(formatter, format: DayFormat, date: date)) ?? 0
        
        // Month
        month = Int(extractDate(formatter, format: MonthFormat, date: date)) ?? 0
        
        // Year
        year = Int(extractDate(formatter, format: YearFormat, date: date)) ?? 0
    }
    
    public init?(date: Date?) {
        guard let date = date else {return nil}
        self.init(date: date)
    }
    
}

// Indexing && Comparing
extension Day: Hashable, Equatable {
    public static func ==(lhs: Day, rhs: Day) -> Bool {
        return (lhs.day == rhs.day &&
                lhs.month == rhs.month &&
                lhs.year == rhs.year)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(day)
        hasher.combine(month)
        hasher.combine(year)
    }
}

fileprivate func extractDate(_ formatter: DateFormatter, format: String, date: Date) -> String {
    formatter.dateFormat = format
    return formatter.string(from: date)
}

// MARK: Date comparision

public func ==(lhs: Day, rhs: Date) -> Bool {
    let formatter = DateFormatter()
    guard let day = Int(extractDate(formatter, format: DayFormat, date: rhs)),
          let month = Int(extractDate(formatter, format: MonthFormat, date: rhs)),
          let year = Int(extractDate(formatter, format: YearFormat, date: rhs)) else
    {return false}
    
    return (lhs.day == day &&
            lhs.month == month &&
            lhs.year == year)
}

public func ==(lhs: Date, rhs: Day) -> Bool {
    rhs == lhs
}

public extension Day {
    static func +(lhs: Day, rhs: Int) -> Day {
        return .init(date: Calendar.current.date(byAdding: .day, value: rhs, to: lhs.date) ?? lhs.date)
    }
    
    static func +=(lhs: inout Day, rhs: Int) {
        lhs = .init(date: lhs.date + rhs)
    }
    
    static func -(lhs: Day, rhs: Int) -> Day {
        return .init(date: Calendar.current.date(byAdding: .day, value: -rhs, to: lhs.date) ?? lhs.date)
    }
    
    static func -=(lhs: inout Day, rhs: Int) {
        lhs = .init(date: lhs.date - rhs)
    }
}

extension Date {
    func isSameDay(_ rhs: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: rhs, toGranularity: .day)
    }
    
    func setMidnight() -> Date {
        let calendar = Calendar.current
        
        // Extract the date components (year, month, and day)
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        
        // Create a new date with the extracted components and set the time to midnight
        return calendar.date(from: components)!
    }
    
    static func +(lhs: Date, rhs: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: rhs, to: lhs) ?? lhs
    }
    
    static func +=(lhs: inout Date, rhs: Int) {
        lhs = lhs + rhs
    }
    
    static func -(lhs: Date, rhs: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -rhs, to: lhs) ?? lhs
    }
    
    static func -=(lhs: inout Date, rhs: Int) {
        lhs = lhs - rhs
    }
    
}
