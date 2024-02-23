//
//  ListWorkoutIOPort.swift
//  
//
//  Created by harsh vishwakarma on 23/12/23.
//

import Foundation

public enum ListWorkoutFilter {
    case none
    case today(limit: Int? = nil)
    case date(Date, limit: Int? = nil)
    case dates(date1: Date, date2: Date, limit: Int? = nil)
    case count(Int)
}

public protocol ListWorkoutIOPort: AnyObject {
    func fetchWorkouts(_ filter: ListWorkoutFilter) async throws -> [Workout]
//    func fetchWorkouts(_ filter: ListWorkoutFilter) async throws -> [Date: [WorkoutRecord]]
    func deleteWorkouts(_ workouts: [Workout]) async throws -> Bool
}
