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

public func formatTime(_ time: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: time) ?? time.formatted()
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

public extension CGSize {
    static prefix func -(size: CGSize) -> CGSize {
        return CGSize(width: -size.width, height: -size.height)
    }
}

public struct AccentedLabeledContentStyle: LabeledContentStyle {
    public func makeBody(configuration: Configuration) -> some View {
        LabeledContent(configuration)
            .foregroundColor(.accentColor)
    }
}

public extension LabeledContentStyle where Self == AccentedLabeledContentStyle {
    static var accented: AccentedLabeledContentStyle { .init() }
}

public struct VerticalLabeledContentStyle: LabeledContentStyle {
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
    }
}

public extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
    static var vertical: VerticalLabeledContentStyle { .init() }
}

