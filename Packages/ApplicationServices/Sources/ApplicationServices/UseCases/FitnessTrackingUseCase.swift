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

    public func trackCaloriesBurned(metValue: Double, weight: Double, repCountUnit: RepCountUnit, duration: TimeInterval, rep: Int) -> Double {
        switch repCountUnit {
        case .time:
            fitnessCalculatorService.calculateCaloriesBurned(metValue: metValue, weight: weight, duration: duration)
        case .rep:
            fitnessCalculatorService.calculateCaloriesBurned(metValue: metValue, weight: weight, rep: rep)
        }
    }
    
    public func isValid(set: Rep, forExercise exercise: Exercise) -> Bool {
        return false
        // Weight Validation
//        let weightValidation = {
//            let weightRequired = exercise.template.mechanic != nil
//            let isWeightAdded = set.weight > .zero
//            return !weightRequired || weightRequired && isWeightAdded
//        }()
//        
//        // Rep validation
//        let repValidation = {
//            let repRequired = set.type == .rep
//            let isRepAdded = set.rep > 0
//            return !repRequired || repRequired && isRepAdded
//        }()
//        
//        // Time Required
//        let timeValidation = {
//            let timeRequired = set.type == .time
//            let isTimeAdded = set.duration > .zero
//            return !timeRequired || timeRequired && isTimeAdded
//        }()
//        
//        return weightValidation && repValidation && timeValidation
    }
}
