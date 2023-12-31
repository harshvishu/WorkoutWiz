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
    
    public func recordWorkout(_ workout: WorkoutRecord) async throws -> WorkoutRecord {
        try await workoutRepository.recordWorkout(workout)
    }
    
    public func deleteWorkout(_ workout: WorkoutRecord) async throws -> Bool {
        try await workoutRepository.deleteWorkout(workout)
    }
}
