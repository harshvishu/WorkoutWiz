//
//  SaveDataIOPort.swift
//
//
//  Created by harsh vishwakarma on 18/12/23.
//

import Foundation

public protocol SaveDataIOPort {
    func createSaveDataFor(exerciseName name: String, sets: [Rep]) async throws -> SaveDataRecord?
    func updateSaveDataFor(record: SaveDataRecord) async throws -> SaveDataRecord?
    func readSavedDataFor(exerciseName name: String) async -> SaveDataRecord?
    func readAllSavedData() async -> [SaveDataRecord]
}

public enum SaveDataError: Error {
    case createFailed(SaveDataCreateError)
    case updateFailed(SaveDataUpdateError)
    case readFailed(SaveDataReadError)
}

public enum SaveDataCreateError {
    case duplicate
}

public enum SaveDataReadError {
    case noRecordFound
}

public enum SaveDataUpdateError {
    case noRecordFound
}
