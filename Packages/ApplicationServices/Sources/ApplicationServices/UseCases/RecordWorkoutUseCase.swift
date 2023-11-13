//
//  RecordWorkoutUseCase.swift
//  
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain

public final class RecordWorkoutUseCase: RecordWorkoutInputPort {
    public weak var output: RecordWorkoutOutputPort?
    var workoutRepository: WorkoutRepository
    
    public init(output: RecordWorkoutOutputPort? = nil, workoutRepository: WorkoutRepository) {
        self.output = output
        self.workoutRepository = workoutRepository
    }
    
    public func recordWorkout(_ workout: Domain.Workout) async {
        // TODO: Actual work
        let result = await workoutRepository.recordWorkout(workout)
        self.output?.workoutRecordedwithResult(result)
    }
    
}
