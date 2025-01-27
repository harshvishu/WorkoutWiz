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

public let hoursMinutesFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
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

public func getDateComponentsFormatter(_ timeInterval: TimeInterval, short: Bool = false) -> DateComponentsFormatter {
    if timeInterval > 3600 {
        if short {
            hoursMinutesFormatter
        } else {
            hoursMinutesSecondsFormatter
        }
    } else if timeInterval > 60 {
        minutesSecondsFormatter
    } else {
        secondsFormatter
    }
}

public func timeInterval(from timeString: String, formatter: DateComponentsFormatter) -> TimeInterval? {
    let components = timeString.components(separatedBy: ":")
    guard !components.isEmpty else {
        return nil
    }
    
    var hour = 0
    var minute = 0
    var second = 0
    
    switch formatter {
    case hoursMinutesSecondsFormatter:
        guard components.count >= 3,
              let hours = Int(components[0]),
              let minutes = Int(components[1]),
              let seconds = Int(components[2]) else {
            return nil
        }
        hour = hours
        minute = minutes
        second = seconds
    case minutesSecondsFormatter:
        guard components.count >= 2,
              let minutes = Int(components[0]),
              let seconds = Int(components[1]) else {
            return nil
        }
        minute = minutes
        second = seconds
    case secondsFormatter:
        guard components.count >= 1,
              let seconds = Int(components[0]) else {
            return nil
        }
        second = seconds
    default:
        return nil
    }
    
    return TimeInterval(hour * 3600 + minute * 60 + second)
}
