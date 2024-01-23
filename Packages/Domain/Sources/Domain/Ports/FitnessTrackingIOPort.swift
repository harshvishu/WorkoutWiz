//
//  FitnessTrackingIOPort.swift
//  
//
//  Created by harsh vishwakarma on 03/01/24.
//

import Foundation

public protocol FitnessTrackingIOPort {
    func trackCaloriesBurned(metValue: Double, weight: Double, type: SetType, duration: TimeInterval, rep: Int) -> Double
    func isValid(set: ExerciseSet, forExercise exercise: ExerciseRecord) -> Bool
}
