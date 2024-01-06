//
//  ListWorkoutUseCase.swift
//  
//
//  Created by harsh vishwakarma on 23/12/23.
//

import Foundation
import Domain
import OSLog

public final class ListWorkoutUseCase: ListWorkoutIOPort {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ListWorkoutUseCase.self))
    
    var workoutRepository: WorkoutRepository
    
    public init(workoutRepository: WorkoutRepository) {
        self.workoutRepository = workoutRepository
    }
    
    @MainActor
    public func listWorkouts(_ filter: ListWorkoutFilter) async throws -> [WorkoutRecord] {
        try await workoutRepository.fetchWorkouts(filter: filter)
    }
    
    @MainActor
    public func deleteWorkouts(_ workouts: [WorkoutRecord]) async throws -> Bool {
        var status = true
        for workout in workouts {
            let op = try await workoutRepository.deleteWorkout(workout)
            if op == false && status == true {
                status = false
            }
        }
        return status
    }
}

