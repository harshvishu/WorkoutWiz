//
//  WorkoutRepository.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain

public protocol WorkoutRepository {
    func emptyWorkout() async -> Workout 
    func createOrUpdateWorkout(_ workout: Workout) async throws -> Bool
    func add(exercise: Exercise, toWorkout workout: Workout) async throws -> Bool
    func add(set: Rep, toExercise exercise: Exercise, toWorkout workout: Workout) async throws -> Bool
    func deleteWorkout(_ workout: Workout) async throws -> Bool
    func fetchWorkouts(filter: ListWorkoutFilter) async throws -> [Workout]
}
