//
//  FitnessTrackingIOPort.swift
//  
//
//  Created by harsh vishwakarma on 03/01/24.
//

import Foundation

public protocol FitnessTrackingIOPort {
    func trackCaloriesBurned(metValue: Double, weight: Double, repCountUnit: RepCountUnit, duration: TimeInterval, rep: Int) -> Double
    func isValid(set: Rep, forExercise exercise: Exercise) -> Bool
}
