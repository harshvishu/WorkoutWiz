// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI

public extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSince(rhs)
    }
}

public func getTimeDifference(startDate: Date, endDate: Date) -> TimeInterval {
    return endDate.timeIntervalSince(startDate)
}

public extension Collection {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

public extension Array {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

public extension Optional where Wrapped == String {
    private var _bound: String? {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    
    var bound: String {
        get {
            return _bound ?? ""
        }
        set {
            _bound = newValue.isEmpty ? nil : newValue
        }
    }
}

public func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
