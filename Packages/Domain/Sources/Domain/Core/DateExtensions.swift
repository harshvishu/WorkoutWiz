//
//  DateExtensions.swift
//
//
//  Created by harsh vishwakarma on 04/01/24.
//

import Foundation

infix operator ===

public func ===(lhs: Date, rhs: Date) -> Bool {
    Calendar.current.isDate(lhs, inSameDayAs: rhs)
}

public func extractDate(date: Date, format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: date)
}

public func dateByAddingMonth(count: Int, toDate date: Date) -> Date? {
    let calendar = Calendar.current
    return calendar.date(byAdding: .month, value: count, to: date)
}

public func dateByAddingDay(count: Int, toDate date: Date) -> Date {
    let calendar = Calendar.current
    return calendar.date(byAdding: .day, value: count, to: date) ?? date
}

public extension Date {
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

public let hoursMinutesSecondsFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    return formatter
}()

public let minutesSecondsFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    return formatter
}()

public let secondsFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    return formatter
}()

public let ordinalFormatter:  NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter
}()

public func getDateComponentsFormatter(_ timeInterval: TimeInterval) -> DateComponentsFormatter {
    if timeInterval > 3600 {
        return hoursMinutesSecondsFormatter
    } else if timeInterval > 60 {
        return minutesSecondsFormatter
    } else {
        return secondsFormatter
    }
}
