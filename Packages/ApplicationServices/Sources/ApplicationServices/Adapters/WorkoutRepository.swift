//
//  WorkoutRepository.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain

public protocol WorkoutRepository {
    func createOrUpdateWorkout(_ workout: WorkoutRecord) async throws -> WorkoutRecord 
    func deleteWorkout(_ workout: WorkoutRecord) async throws -> Bool
    func fetchWorkouts(filter: ListWorkoutFilter) async throws -> [WorkoutRecord]
}
