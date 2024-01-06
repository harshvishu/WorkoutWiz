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
    func listWorkouts(_ filter: ListWorkoutFilter) async throws -> [WorkoutRecord]
    func deleteWorkouts(_ workouts: [WorkoutRecord]) async throws -> Bool
}
