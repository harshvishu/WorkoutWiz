//
//  Unit.swift
//
//
//  Created by harsh vishwakarma on 13/12/23.
//

import Foundation

public enum Unit: Hashable, Codable {
    case kg
    case pound
}

public extension Unit {
    var symbol: String {
        switch self {
        case .kg: "kg"
        case .pound: "lbs"
        }
    }
}
