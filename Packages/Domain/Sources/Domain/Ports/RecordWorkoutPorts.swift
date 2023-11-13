//
//  RecordWorkoutPorts.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation

public protocol RecordWorkoutOutputPort: AnyObject {
    func workoutRecordedwithResult(_ result: Result<Workout, Error>)
}

public protocol RecordWorkoutInputPort {
    func recordWorkout(_ workout: Workout) async
}
