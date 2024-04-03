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
    public var preferredHeightUnit = HeightUnit.meter
    
    public init(weight: Double, height: Double, preferredWeightUnit: WeightUnit = WeightUnit.kg, preferredHeightUnit: HeightUnit = HeightUnit.meter) {
        self.weight = weight
        self.height = height
        self.preferredWeightUnit = preferredWeightUnit
        self.preferredHeightUnit = preferredHeightUnit
    }
    
    public init() {}
}
