//
//  RecordWorkoutView.swift
//  
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Observation
import Domain
import ApplicationServices
import Persistence

@Observable
public final class RecordWorkoutViewModel: RecordWorkoutOutputPort, ListExerciseOutputPort {
    
    private let recordWorkoutUseCase: RecordWorkoutInputPort
    private let listExerciseUseCase: ListExerciseInputPort
    
    public private(set) var exercies: [Exercise] = []
    
    public init(recordWorkoutUseCase: RecordWorkoutInputPort = RecordWorkoutUseCase(workoutRepository: FirebaseWorkoutRepository()), listExerciseUseCase: ListExerciseInputPort = ListExerciseUseCase(exerciseRepository: SwiftDataExerciseRepository())) {
        self.recordWorkoutUseCase = recordWorkoutUseCase
        self.listExerciseUseCase = listExerciseUseCase
        
        (recordWorkoutUseCase as? RecordWorkoutUseCase)?.output = self
        (listExerciseUseCase as? ListExerciseUseCase)?.output = self
    }

    @MainActor
    public func workoutRecordedwithResult(_ result: Result<Domain.Workout, Error>) {
        switch result {
        case .success(let workout):
            print(workout)
        case .failure(let error):
            print(error)
        }
    }	
    
    public func recordWorkout(_ workout: Workout) async {
        await recordWorkoutUseCase.recordWorkout(workout)
    }
    
    @MainActor
    public func displayExercises(_ exercises: [Exercise]) {
        self.exercies = exercises
    }
}
