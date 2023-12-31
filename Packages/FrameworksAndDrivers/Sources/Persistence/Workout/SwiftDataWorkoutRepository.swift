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
    
    public func recordWorkout(_ workout: WorkoutRecord) async throws -> WorkoutRecord {
        let descriptor = fetchDescriptor(filterByDocumentID: workout.documentID, fetchLimit: 1)
        if let model = try modelContext.fetch(descriptor).first {
            model.update(fromRecord: workout)
            logger.info("\(model.documentID) Model updated")
            return workout
        } else {
            let record = SD_WorkoutRecord(workout)
            modelContext.insert(record)
            logger.info("\(record.documentID) Model inserted")
            return workout
        }
    }
    
    public func fetchWorkouts() async throws -> [WorkoutRecord] {
        let descriptor = FetchDescriptor<SD_WorkoutRecord>()
        return try modelContext.fetch(descriptor).map(WorkoutRecord.init)
    }
    
    public func deleteWorkout(_ workout: WorkoutRecord) async throws -> Bool {
        let descriptor = fetchDescriptor(filterByDocumentID: workout.documentID, fetchLimit: 1)
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
            logger.info("\(model.documentID) Model updated")
            return model.isDeleted
        } else {
            // data was never written
            return true
        }
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
