//
//  ExerciseSet.swift
//  
//
//  Created by harsh vishwakarma on 18/12/23.
//

import Foundation

public struct ExerciseSet: Hashable, Equatable, Codable {
    public var weight: Double
    public var rep: Int
    public var unit: Unit
    public var failure: Bool
    
    public init(weight: Double, rep: Int, unit: Unit = .kg, failure: Bool = false) {
        self.weight = weight
        self.rep = rep
        self.unit = unit
        self.failure = failure
    }
}
