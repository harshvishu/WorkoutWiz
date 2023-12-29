//
//  SaveDataRepository.swift
//
//
//  Created by harsh vishwakarma on 18/12/23.
//

import Foundation
import Domain

public protocol SaveDataRepository {
    func readSaveData() async -> [SaveDataRecord]
    func readSaveData(forExerciseName name: String) async -> SaveDataRecord?
    func createRecord(exerciseName name: String, sets: [ExerciseSet]) async throws -> SaveDataRecord?
    func update(record: SaveDataRecord) async throws -> SaveDataRecord?
}
