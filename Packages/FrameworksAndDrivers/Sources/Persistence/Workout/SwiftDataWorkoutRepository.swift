//
//  SwiftDataWorkoutRepository.swift
//
//
//  Created by harsh vishwakarma on 20/11/23.
//

import Foundation
import Domain
import ApplicationServices
import SwiftData
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: SwiftDataWorkoutRepository.self))

public final class SwiftDataWorkoutRepository: WorkoutRepository {
    
    private var modelContext: ModelContext
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func emptyWorkout() async -> Workout {
        let workout = Workout()
        return workout
    }
    
    public func createOrUpdateWorkout(_ workout: Workout) async throws -> Bool {
        let descriptor = fetchDescriptor(filterByID: workout.id, fetchLimit: nil)
        if try modelContext.fetchCount(descriptor) > 0 {
            logger.info("\(workout.id) Workout already exists")
        } else {
            modelContext.insert(workout)
            logger.info("\(workout.id) New Workout Inserted")
        }
        
//        try modelContext.save()
        return true
    }
    
    public func add(exercise: Exercise, toWorkout workout: Workout) async throws -> Bool {
        modelContext.insert(exercise)
//        workout.exercises.append(exercise)
//        workout.updateMetrics()
//        
        logger.info("Exercises inserted")
        
//        try modelContext.save()
        return true
    }
    
    public func add(set: Rep, toExercise exercise: Exercise, toWorkout workout: Workout) async throws -> Bool {
        
        modelContext.insert(set)
        exercise.reps.append(set)
        
        // TODO:
//        exercise.updateMetrics()
//        workout.updateMetrics()
        
        logger.info("Set inserted")
        
//        try modelContext.save()
        
        return true
    }
    
    public func deleteWorkout(_ workout: Workout) async throws -> Bool {
        let descriptor = fetchDescriptor(filterByID: workout.id, fetchLimit: nil)
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            logger.info("\(model.id) Workout deleted")
            return model.isDeleted
        } else {
            // Data was never written. Safe to remove from UI
            logger.info("Workout not peresisted. Not deleted")
            return true
        }
    }
    
    public func fetchWorkouts(filter: ListWorkoutFilter) async throws -> [Workout] {
        let descriptor = fetchDescriptorForWorkout(filter: filter)
        let workouts = try modelContext.fetch(descriptor)
        return workouts
    }
}

fileprivate extension SwiftDataWorkoutRepository {
    func fetchDescriptor(filterByID ID: UUID, fetchLimit limit: Int?) -> FetchDescriptor<Workout> {
        var descriptor = FetchDescriptor<Workout>(predicate: #Predicate {
            $0.id == ID
        })
        descriptor.fetchLimit = limit
        return descriptor
    }
    
    func fetchDescriptorForWorkout(filter: ListWorkoutFilter) -> FetchDescriptor<Workout> {
        var descriptor = FetchDescriptor<Workout>()
        switch filter {
        case .none:
            break
        case .today(let limit):
            descriptor.predicate = predicate(start: Date(), end: Date())
            if let limit = limit {
                descriptor.fetchLimit = limit
            }
        case .date(let date, let limit):
            descriptor.predicate = predicate(start: date, end: date)
            if let limit = limit {
                descriptor.fetchLimit = limit
            }
        case .dates(let date1, let date2, let limit):
            descriptor.predicate = predicate(start: date1, end: date2)
            if let limit = limit {
                descriptor.fetchLimit = limit
            }
        case .count(let count):
            descriptor.fetchLimit = count
        }
        return descriptor
    }
    
    func predicate(
        start: Date,
        end: Date
    ) -> Predicate<Workout> {
        let calendar = Calendar.autoupdatingCurrent
        let start = calendar.startOfDay(for: start)
        let end = calendar.date(byAdding: .init(day: 1), to: calendar.startOfDay(for: end)) ?? end
        
        return #Predicate<Workout> {
            $0.startDate > start && $0.startDate < end
        }
    }
}
