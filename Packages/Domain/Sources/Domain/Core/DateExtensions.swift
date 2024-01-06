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
    
}

