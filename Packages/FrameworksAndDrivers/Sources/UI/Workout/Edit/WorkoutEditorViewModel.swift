//
//  WorkoutEditorViewModel.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Observation
import Domain
import ApplicationServices
import Persistence
import Foundation
import DesignSystem
import SwiftData
import OSLog

@Observable
public final class WorkoutEditorViewModel {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: WorkoutEditorViewModel.self))
    
    var recordWorkoutUseCase: RecordWorkoutIOPort?
    var listExerciseUseCase: ListExerciseIOPort?
    var fitnessTrackingUseCase: FitnessTrackingIOPort
        
    var isWorkoutActive: Bool = false
    var startDate: Date = .now
    var calories: Double = 0.0
    
    public init(
        recordWorkoutUseCase: RecordWorkoutIOPort? = nil,
        listExerciseUseCase: ListExerciseIOPort = ListExerciseUseCase(exerciseRepository: UserDefaultsExerciseTemplateRepository()),
        fitnessTrackingUseCase: FitnessTrackingIOPort = FitnessTrackingUseCase()
    ) {
        self.recordWorkoutUseCase = recordWorkoutUseCase
        self.listExerciseUseCase = listExerciseUseCase
        self.fitnessTrackingUseCase = fitnessTrackingUseCase
    }

    func isWorkoutInProgress(workout: Workout) -> Bool {
        workout.exercises.isNotEmpty || isWorkoutActive  // TODO:
    }
    
    func isCurrentWorkoutValid(workout: Workout) -> Bool {
        let isWorkoutInvalid = workout.exercises.first { exercise in
            exercise.reps.first { set in
                !fitnessTrackingUseCase.isValid(set: set, forExercise: exercise)
            } != nil
        } != nil
        return !isWorkoutInvalid
    }
    
    func reset() {
        isWorkoutActive = false
        startDate = .now
        calories = 0.0
    }
    
    func resume(workout: Workout) -> Bool {
        guard !isWorkoutActive else {return false}
        isWorkoutActive = true
        startDate = workout.startDate
        calories = workout.calories
        return true
    }
}
