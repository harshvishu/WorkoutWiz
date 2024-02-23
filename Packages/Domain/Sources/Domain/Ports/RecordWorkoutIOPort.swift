//
//  RecordWorkoutIOPort.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation

public enum RecordWorkoutError: Error {
    case writeFailed
}

public protocol RecordWorkoutIOPort {
    func emptyWorkout() async throws -> Workout 
    func add(workout: Workout) async throws -> Bool
    func add(exercise: Exercise, toWorkout workout: Workout) async throws -> Bool
    func add(set: Rep, toExercise exercise: Exercise, toWorkout workout: Workout) async throws -> Bool
    func deleteWorkout(_ workout: Workout) async throws -> Bool
}
