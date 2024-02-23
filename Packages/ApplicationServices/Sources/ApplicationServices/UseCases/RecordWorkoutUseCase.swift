//
//  RecordWorkoutUseCase.swift
//  
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain
import OSLog

public final class RecordWorkoutUseCase: RecordWorkoutIOPort {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: RecordWorkoutIOPort.self))
    
    private var workoutRepository: WorkoutRepository
    
    public init(workoutRepository: WorkoutRepository) {
        self.workoutRepository = workoutRepository
    }
    
    public func emptyWorkout() async throws -> Workout {
        await workoutRepository.emptyWorkout()
    }
    
    public func add(workout: Workout) async throws -> Bool {
        try await workoutRepository.createOrUpdateWorkout(workout)
    }
    
    public func add(exercise: Exercise, toWorkout workout: Workout) async throws -> Bool {
        try await workoutRepository.add(exercise: exercise, toWorkout: workout)
    }
    
    public func add(set: Rep, toExercise exercise: Exercise, toWorkout workout: Workout) async throws -> Bool {
        try await workoutRepository.add(set: set, toExercise: exercise, toWorkout: workout)
    }
    
    public func deleteWorkout(_ workout: Workout) async throws -> Bool {
        try await workoutRepository.deleteWorkout(workout)
    }
}
