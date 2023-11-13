//
//  RecordWorkoutView.swift
//  
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Observation
import Domain
import ApplicationServices

@Observable
public final class RecordWorkoutViewModel: RecordWorkoutOutputPort {
    public private(set) var workout: Workout = Workout()
    
    private let recordWorkoutUseCase: RecordWorkoutInputPort
    
    public init(recordWorkoutUseCase: RecordWorkoutInputPort) {
        self.recordWorkoutUseCase = recordWorkoutUseCase
        (recordWorkoutUseCase as? RecordWorkoutUseCase)?.output = self
    }

    @MainActor
    public func workoutRecordedwithResult(_ result: Result<Domain.Workout, Error>) {
        switch result {
        case .success(let workout):
            self.workout = workout
        case .failure(let error):
            print(error)
        }
    }
    
    public func recordWorkout() async {
        await recordWorkoutUseCase.recordWorkout(workout)
    }
}
