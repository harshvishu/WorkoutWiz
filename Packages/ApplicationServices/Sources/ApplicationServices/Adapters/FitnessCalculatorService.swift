//
//  FitnessCalculatorService.swift
//  
//
//  Created by harsh vishwakarma on 03/01/24.
//

import Foundation

public class FitnessCalculatorService {
    public init() {}
    
    public func calculateCaloriesBurned(metValue: Double, weight: Double, duration: Double) -> Double {
        let calories = (metValue * weight * duration) / 200.0
        return calories
    }
    
    public func calculateCaloriesBurned(metValue: Double, weight: Double, rep: Int) -> Double {
        calculateCaloriesBurned(metValue: metValue, weight: weight, duration: Double(rep))
    }
}
