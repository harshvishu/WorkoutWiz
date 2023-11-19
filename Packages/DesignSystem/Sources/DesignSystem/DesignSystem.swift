// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSince(rhs)
    }
}

public func getTimeDifference(startDate: Date, endDate: Date) -> TimeInterval {
    return endDate.timeIntervalSince(startDate)
}
