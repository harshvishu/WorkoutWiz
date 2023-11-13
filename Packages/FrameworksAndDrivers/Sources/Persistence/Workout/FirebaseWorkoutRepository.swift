//
//  FirebaseWorkoutRepository.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain
import ApplicationServices

public final class FirebaseWorkoutRepository: WorkoutRepository {
    public init() {}
    
    public func recordWorkout(_ workout: Workout) async -> Result<Workout, Error> {
        if workout.duration > 5.0 {
            return .success(workout)
        } else {
            return .failure(RecordWorkoutError.writeFailed)
        }
    }
}
