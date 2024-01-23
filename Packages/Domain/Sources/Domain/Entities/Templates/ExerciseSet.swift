//
//  ExerciseSet.swift
//
//
//  Created by harsh vishwakarma on 18/12/23.
//

import Foundation

public struct ExerciseSet: Hashable, Equatable, Codable {
    public var id = UUID()
    public var exerciseID: UUID
    public var weight: Double
    public var type: SetType
    public var duration: TimeInterval
    public var rep: Int
    public var unit: Unit
    public var failure: Bool
    public var calories: Double
    
    public init(exerciseID: UUID, weight: Double, type: SetType, duration: TimeInterval, rep: Int, unit: Unit = .kg, failure: Bool = false, calories: Double) {
        self.exerciseID = exerciseID
        self.weight = weight
        self.type = type
        self.duration = duration
        self.rep = rep
        self.unit = unit
        self.failure = failure
        self.calories = calories
    }
    
    public mutating func update(weight: Double? = nil, type: SetType? = nil, duration: TimeInterval? = nil, rep: Int? = nil, unit: Unit? = nil, failure: Bool? = nil, calories: Double? = nil) {
        if let weight = weight {
            self.weight = weight
        }
        if let type = type {
            self.type = type
        }
        if let duration = duration {
            self.duration = duration
        }
        if let rep = rep {
            self.rep = rep
        }
        if let unit = unit {
            self.unit = unit
        }
        if let failure = failure {
            self.failure = failure
        }
        if let calories = calories {
            self.calories = calories
        }
    }
}

public enum SetType: Codable, Hashable, Equatable {
    case rep
    case duration
}
