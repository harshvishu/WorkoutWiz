//
//  RecordWorkoutPorts.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation

public enum RecordWorkoutError: Error {
    case writeFailed
}

public protocol RecordWorkoutOutputPort: AnyObject {
    func workoutRecordedwithResult(_ result: Result<Workout, Error>)
}

public protocol RecordWorkoutInputPort {
    func recordWorkout(_ workout: Workout) async
}
