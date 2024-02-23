//
//  SwiftDataSaveDataRepository.swift
//
//
//  Created by harsh vishwakarma on 18/12/23.
//

import Foundation
import Domain
import ApplicationServices
import SwiftData

public final class SwiftDataSaveDataRepository: SaveDataRepository {
    
    private var modelContext: ModelContext
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func readSaveData() async -> [SaveDataRecord] {
        let descriptor = FetchDescriptor<SD_SaveDataRecord>()
        let allRecords = try? modelContext.fetch(descriptor)
        
        return allRecords?.map(SaveDataRecord.init) ?? []
    }
    
    public func readSaveData(forExerciseName name: String) async -> SaveDataRecord? {
        var descriptor = FetchDescriptor<SD_SaveDataRecord>()
        descriptor.predicate = #Predicate {
            $0.exerciseName == name
        }
        descriptor.fetchLimit = 1
        
        let allRecords = try? modelContext.fetch(descriptor)
        return allRecords?.first.map(SaveDataRecord.init)
    }
    
    public func createRecord(exerciseName name: String, sets: [Rep]) async throws -> SaveDataRecord? {
        let record = SaveDataRecord(exerciseName: name, sets: sets)
        let descriptor = fetchDescriptor(filterByExerciseName: name, fetchLimit: 1)
        
        let filteredRecords = try modelContext.fetch(descriptor)
        guard filteredRecords.isEmpty else {
            throw SaveDataError.createFailed(.duplicate)
        }
        
        let saveData = SD_SaveDataRecord(record)
        modelContext.insert(saveData)
        return record
    }
    
    public func update(record: SaveDataRecord) async throws -> SaveDataRecord? {
        let descriptor = fetchDescriptor(filterByDocumentID: record.documentID, fetchLimit: 1)
        
        let filteredRecords = try modelContext.fetch(descriptor)
        guard let sd_savedData = filteredRecords.first else {
            throw SaveDataError.updateFailed(.noRecordFound)
        }
        
        sd_savedData.date = record.date
        sd_savedData.sets = record.sets
        sd_savedData.exerciseName = record.exerciseName
        
        return record
    }
}

fileprivate extension SwiftDataSaveDataRepository {
    func fetchDescriptor(filterByDocumentID documentID: String, fetchLimit limit: Int) -> FetchDescriptor<SD_SaveDataRecord> {
        var descriptor = FetchDescriptor<SD_SaveDataRecord>(predicate: #Predicate {
            $0.documentID == documentID
        })
        descriptor.fetchLimit = limit
        return descriptor
    }
    
    func fetchDescriptor(filterByExerciseName exerciseName: String, fetchLimit limit: Int) -> FetchDescriptor<SD_SaveDataRecord> {
        var descriptor = FetchDescriptor<SD_SaveDataRecord>(predicate: #Predicate {
            $0.exerciseName == exerciseName
        })
        descriptor.fetchLimit = limit
        return descriptor
    }
}

// MARK: - Model Files

@Model
class SD_SaveDataRecord {
    @Attribute(.unique)
    var documentID: String
    var date: Date
    
    @Relationship(deleteRule: .cascade)
    var exerciseName: String
    var sets: [Rep]
    
    init(documentID: String, date: Date = .now, exerciseName: String, sets: [Rep]) {
        self.documentID = documentID
        self.date = date
        self.exerciseName = exerciseName
        self.sets = sets
    }
    
    convenience init(_ record: SaveDataRecord) {
        self.init(
            documentID: record.documentID,
            date: record.date,
            exerciseName: record.exerciseName,
            sets: record.sets
        )
    }
}

extension SaveDataRecord {
    init(_ record: SD_SaveDataRecord) {
        self.init(documentID: record.documentID, date: record.date, exerciseName: record.exerciseName, sets: record.sets)
    }
}
