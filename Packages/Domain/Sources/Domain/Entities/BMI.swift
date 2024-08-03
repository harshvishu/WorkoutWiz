//
//  BMI.swift
//  
//
//  Created by harsh vishwakarma on 02/04/24.
//

import Foundation

// MARK: BMI
public struct BMI: Codable, Equatable {
    public var weight: Double = 0.0
    public var height: Double = 0.0
    public var preferredWeightUnit = WeightUnit.kg
    public var preferredHeightUnit = HeightUnit.centimeter
    public var preferredDistanceUnit = DistanceUnit.kilometers
    
    public init(weight: Double, height: Double, preferredWeightUnit: WeightUnit = WeightUnit.kg, preferredHeightUnit: HeightUnit = HeightUnit.centimeter, preferredDistanceUnit: DistanceUnit = .kilometers) {
        self.weight = weight
        self.height = height
        self.preferredWeightUnit = preferredWeightUnit
        self.preferredHeightUnit = preferredHeightUnit
        self.preferredDistanceUnit = preferredDistanceUnit
    }
    
    public init() {}
}
