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

public final class SwiftDataWorkoutRepository: WorkoutRepository {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: SwiftDataWorkoutRepository.self))
    
    private var modelContext: ModelContext
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func createOrUpdateWorkout(_ workout: WorkoutRecord) async throws -> WorkoutRecord {
        let descriptor = fetchDescriptor(filterByDocumentID: workout.documentID, fetchLimit: 1)
        if let model = try modelContext.fetch(descriptor).first {
            model.update(fromRecord: workout)
            logger.info("\(model.documentID) Workout updated")
            return workout
        } else {
            let record = SD_WorkoutRecord(workout)
            modelContext.insert(record)
            logger.info("\(record.documentID) Workout inserted")
            return workout
        }
    }
    
    public func deleteWorkout(_ workout: WorkoutRecord) async throws -> Bool {
        let descriptor = fetchDescriptor(filterByDocumentID: workout.documentID, fetchLimit: 1)
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            logger.info("\(model.documentID) Workout deleted")
            return model.isDeleted
        } else {
            // Data was never written. Safe to remove from UI
            logger.info("Workout not peresisted. Not deleted")
            return true
        }
    }
    public func fetchWorkouts(filter: ListWorkoutFilter) async throws -> [WorkoutRecord] {
        let descriptor = fetchDescriptor(filter: filter)
        return try modelContext.fetch(descriptor).map(WorkoutRecord.init)
    }
}

fileprivate extension SwiftDataWorkoutRepository {
    func fetchDescriptor(filterByDocumentID documentID: String, fetchLimit limit: Int) -> FetchDescriptor<SD_WorkoutRecord> {
        var descriptor = FetchDescriptor<SD_WorkoutRecord>(predicate: #Predicate {
            $0.documentID == documentID
        })
        descriptor.fetchLimit = limit
        return descriptor
    }
    
    func fetchDescriptor(filter: ListWorkoutFilter) -> FetchDescriptor<SD_WorkoutRecord> {
        var descriptor = FetchDescriptor<SD_WorkoutRecord>()
        
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
    ) -> Predicate<SD_WorkoutRecord> {
        let calendar = Calendar.autoupdatingCurrent
        let start = calendar.startOfDay(for: start)
        let end = calendar.date(byAdding: .init(day: 1), to: calendar.startOfDay(for: end)) ?? end
        
        return #Predicate<SD_WorkoutRecord> {
            $0.startDate > start && $0.startDate < end
        }
    }
}

@Model
public class SD_WorkoutRecord {
    
    @Attribute(.unique)
    public var documentID: String
    public var name: String
    public var startDate: Date
    public var endDate: Date
    public var duration: TimeInterval
    public var notes: String?
    public var exercises: [ExerciseRecord]
    
    init(documentID: String, name: String, startDate: Date, endDate: Date, duration: TimeInterval, notes: String? = nil, exercises: [ExerciseRecord]) {
        self.documentID = documentID
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.notes = notes
        self.exercises = exercises
    }
    
    convenience init(_ record: WorkoutRecord) {
        self.init(
            documentID: record.documentID,
            name: record.name,
            startDate: record.startDate,
            endDate: record.endDate,
            duration: record.duration,
            notes: record.notes,
            exercises: record.exercises
        )
    }
    
    func update(fromRecord record: WorkoutRecord) {
        self.documentID = record.documentID
        self.name = record.name
        self.startDate = record.startDate
        self.endDate = record.endDate
        self.duration = record.duration
        self.notes = record.notes
        self.exercises = record.exercises
    }
}

extension WorkoutRecord {
    init(_ record: SD_WorkoutRecord) {
        self.init(
            documentID: record.documentID,
            name: record.name,
            startDate: record.startDate,
            endDate: record.endDate,
            duration: record.duration,
            notes: record.notes,
            exercises: record.exercises
        )
    }
}
