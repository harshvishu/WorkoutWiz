//
//  FoundationExtensions.swift
//  
//
//  Created by harsh vishwakarma on 19/01/24.
//

import Foundation
import OSLog

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

// MARK: Logger extensions
public extension Logger {
    func logDebug(_ object: Any) {
        dump(object)
    }
}

public extension Bool {
    func not() -> Bool {
        !self
    }
}
