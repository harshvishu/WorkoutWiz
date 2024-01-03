//
//  DateExtensions.swift
//  
//
//  Created by harsh on 17/09/22.
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
