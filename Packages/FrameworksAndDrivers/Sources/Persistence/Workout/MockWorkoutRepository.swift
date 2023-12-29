//
//  MockWorkoutRepository.swift
//
//
//  Created by harsh vishwakarma on 23/12/23.
//

import Domain
import ApplicationServices

public final class MockWorkoutRepository: WorkoutRepository {
    
    private var workouts: [WorkoutRecord] = [
        WorkoutRecord(documentID: "100001", name: "Biceps", startDate: .distantPast, endDate: .distantFuture, duration: 500, notes: "best bicep workout", exercises: [
            ExerciseRecord(documentID: "7000001", template: .mock_1, sets: [.init(weight: 5, rep: 12), .init(weight: 7.5, rep: 10), .init(weight: 10, rep: 8)]),
            ExerciseRecord(documentID: "7000002", template: .mock_1, sets: [.init(weight: 5, rep: 12), .init(weight: 7.5, rep: 10), .init(weight: 10, rep: 8)])
        ])
    ]
    
    public init() {}
    
    public func recordWorkout(_ workout: WorkoutRecord) async throws -> WorkoutRecord {
        workouts.append(workout)
        return workout
    }
    
    public func fetchWorkouts() async throws -> [WorkoutRecord] {
        workouts
    }
}

