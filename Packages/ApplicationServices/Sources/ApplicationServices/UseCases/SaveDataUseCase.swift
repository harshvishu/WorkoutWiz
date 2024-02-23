//
//  SaveDataUseCase.swift
//
//
//  Created by harsh vishwakarma on 19/12/23.
//


import Foundation
import Domain

public final class SaveDataUseCase: SaveDataIOPort {
    var saveDataRepository: SaveDataRepository
    
    public init(saveDataRepository: SaveDataRepository) {
        self.saveDataRepository = saveDataRepository
    }
    
    public func readAllSavedData() async -> [SaveDataRecord] {
        await saveDataRepository.readSaveData()
    }
    
    public func createSaveDataFor(exerciseName name: String, sets: [Rep]) async throws -> SaveDataRecord? {
        return try await saveDataRepository.createRecord(exerciseName: name, sets: sets)
    }
    
    public func updateSaveDataFor(record: SaveDataRecord) async throws -> SaveDataRecord? {
        return try await saveDataRepository.update(record: record)
    }
    
    public func readSavedDataFor(exerciseName name: String) async -> SaveDataRecord? {
        await saveDataRepository.readSaveData(forExerciseName: name)
    }
    
}

