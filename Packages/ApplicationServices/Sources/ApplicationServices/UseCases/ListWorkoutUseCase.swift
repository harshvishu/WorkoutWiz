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
    public func fetchWorkouts(_ filter: ListWorkoutFilter) async throws -> [Workout] {
        let workouts = try await workoutRepository.fetchWorkouts(filter: filter)
        /*
        logger.debug("Total workouts: \(workouts.count)")
        
        let today = Date()
        let calendar = Calendar.autoupdatingCurrent
//        let start = calendar.startOfDay(for: today)
//        let end = calendar.date(byAdding: .init(day: 1), to: today) ?? today
        
        let dict = Dictionary(grouping: workouts) {
            // 1. Group if Day is today
            calendar.startOfDay(for: $0.startDate)
        }
        
        for (day, records) in dict {
            logger.debug("Day: \(day)")
            for record in records {
                logger.debug("\(record.startDate.formatted())")
            }
        }
        */
        return workouts
    }
    
    @MainActor
    public func deleteWorkouts(_ workouts: [Workout]) async throws -> Bool {
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

