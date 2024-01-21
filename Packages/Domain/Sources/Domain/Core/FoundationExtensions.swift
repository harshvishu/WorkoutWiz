//
//  FoundationExtensions.swift
//  
//
//  Created by harsh vishwakarma on 19/01/24.
//

import Foundation

public extension String {
    var double: Double? {
        Double(self)
    }
    
    var int: Int? {
        Int(self)
    }
}

public extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
