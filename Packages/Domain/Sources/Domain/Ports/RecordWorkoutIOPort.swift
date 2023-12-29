//
//  RecordWorkoutIOPort.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation

public enum RecordWorkoutError: Error {
    case writeFailed
}

public protocol RecordWorkoutIOPort {
    func recordWorkout(_ workout: WorkoutRecord) async throws -> WorkoutRecord
}
