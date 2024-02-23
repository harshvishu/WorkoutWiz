//
//  MockWorkoutRepository.swift
//
//
//  Created by harsh vishwakarma on 23/12/23.
//

import ApplicationServices
import Domain
import Foundation

public final class MockWorkoutRepository: WorkoutRepository {
    
    private var workouts: [Workout] = []
    
    public init() {}
    
    public func emptyWorkout() async -> Workout {
        fatalError()
    }
    
    public func createOrUpdateWorkout(_ workout: Workout) async throws -> Bool {
        return false
    }
    public func deleteWorkout(_ workout: Workout) async throws -> Bool {
        return false
    }
    public func add(set: Rep, toExercise exercise: Exercise, toWorkout workout: Workout) async throws -> Bool {
        return false
    }
    
    public func add(exercise: Exercise, toWorkout workout: Workout) async throws -> Bool {
        return false
    }
    
    public func update(exercise: Exercise) async throws -> Bool {
        return false
    }
    public func fetchWorkouts(filter: ListWorkoutFilter) async throws -> [Workout] {
        workouts
    }
}

