//
//  FoundationExtensions.swift
//  
//
//  Created by harsh vishwakarma on 19/01/24.
//

import Foundation
import OSLog
import SwiftUI

public extension String {
    var double: Double? {
        Double(self)
    }
    
    var int: Int? {
        Int(self)
    }
}

public extension Optional {
    func orDefault(_ value: Wrapped) -> Wrapped {
        self ?? value
    }
}

public extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

public extension Bool {
    func not() -> Bool {
        !self
    }
}

public extension String {
    func highlighted(highlightText: String, highlightColor: Color) -> AttributedString {
        // Initialize an attributed string
        var attributedString = AttributedString(self)
        
        // Find all the ranges where the highlightText matches in the fullText
        let ranges = self.ranges(of: highlightText, options: .caseInsensitive)
        
        // Apply attributes to each matching range
        for range in ranges {
            // Convert String range to AttributedString range
            let nsRange = NSRange(range, in: self)
            if let attributedRange = Range(nsRange, in: attributedString) {
                attributedString[attributedRange].foregroundColor = highlightColor
            }
        }
        
        return attributedString
    }
}

// Extension to find all ranges of a substring in a string
extension String {
    func ranges(of searchString: String, options: String.CompareOptions = .literal) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
              let range = self.range(of: searchString, options: options, range: searchStartIndex..<self.endIndex),
              !range.isEmpty {
            ranges.append(range)
            searchStartIndex = range.upperBound
        }
        
        return ranges
    }
}
