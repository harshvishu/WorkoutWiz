//
//  ExerciseSet.swift
//  
//
//  Created by harsh vishwakarma on 18/12/23.
//

import Foundation

public struct ExerciseSet: Hashable, Equatable, Codable {
    public var id = UUID()
    public var weight: Double
    public var type: SetType
    public var unit: Unit
    public var failure: Bool
    public var calories: Double
    
    public init(weight: Double = 0.0, type: SetType, unit: Unit = .kg, failure: Bool = false, calories: Double = 0.0) {
        self.weight = weight
        self.type = type
        self.unit = unit
        self.failure = failure
        self.calories = calories
    }
    
    public init(weight: Double = 0.0, duration: TimeInterval, unit: Unit = .kg, failure: Bool = false, calories: Double = 0.0) {
        self.weight = weight
        self.type = .duration(duration)
        self.unit = unit
        self.failure = failure
        self.calories = calories
    }
    
    public init(weight: Double = 0.0, rep: Int, unit: Unit = .kg, failure: Bool = false, calories: Double = 0.0) {
        self.weight = weight
        self.type = .rep(rep)
        self.unit = unit
        self.failure = failure
        self.calories = calories
    }
    
    public mutating func update(type: SetType) {
        self.type = type
    }
}

public enum SetType: Codable, Hashable, Equatable {
    case rep(Int)
    case duration(Double)
}
