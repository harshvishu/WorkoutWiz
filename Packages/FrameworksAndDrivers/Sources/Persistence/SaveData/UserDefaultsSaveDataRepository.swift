//
//  UserDefaultsSaveDataRepository.swift
//
//
//  Created by harsh vishwakarma on 18/12/23.
//

import Foundation
import Domain
import ApplicationServices

public final class UserDefaultsSaveDataRepository: SaveDataRepository {
    public func update(record: SaveDataRecord) async -> SaveDataRecord? {
        return nil
    }
    
    public func createRecord(exerciseName name: String, sets: [Rep]) async throws -> SaveDataRecord? {
        return nil
    }
    
    public init() {}
    
    public func readSaveData() async -> [SaveDataRecord] {
        return []
    }
    
    public func readSaveData(forExerciseName id: String) async -> SaveDataRecord? {
        return nil
    }
    
}
