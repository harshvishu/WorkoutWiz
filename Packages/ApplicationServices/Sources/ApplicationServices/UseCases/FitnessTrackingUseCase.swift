//
//  FitnessTrackingUseCase.swift
//  
//
//  Created by harsh vishwakarma on 03/01/24.
//

import Foundation
import Domain

public class FitnessTrackingUseCase: FitnessTrackingIOPort {
    
    let fitnessCalculatorService: FitnessCalculatorService

    public init(fitnessCalculatorService: FitnessCalculatorService = FitnessCalculatorService()) {
        self.fitnessCalculatorService = fitnessCalculatorService
    }

    public func trackCaloriesBurned(metValue: Double, weight: Double, type: SetType, duration: TimeInterval, rep: Int) -> Double {
        switch type {
        case .duration:
            fitnessCalculatorService.calculateCaloriesBurned(metValue: metValue, weight: weight, duration: duration)
        case .rep:
            fitnessCalculatorService.calculateCaloriesBurned(metValue: metValue, weight: weight, rep: rep)
        }
    }
}
