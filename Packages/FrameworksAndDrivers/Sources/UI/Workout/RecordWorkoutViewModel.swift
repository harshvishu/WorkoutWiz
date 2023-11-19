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
import Foundation
import DesignSystem

@Observable
public final class RecordWorkoutViewModel: RecordWorkoutOutputPort, ListExerciseOutputPort {
    
    private let recordWorkoutUseCase: RecordWorkoutInputPort
    private let listExerciseUseCase: ListExerciseInputPort
    
    public private(set) var exercies: [Exercise] = []
    
    /// private properties
    public private(set) var isTimerRunning: Bool = false
    public private(set) var startTime: Date? = nil
    public private(set) var workout: Workout? = nil
    
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
    
    func startTimer() async {
        guard !isTimerRunning else {return}
        isTimerRunning = true
        startTime = Date()
        workout = Workout()
    }
    
    func endTimer() async -> Bool {
        guard isTimerRunning,
              let startTime = self.startTime,
              var workout = self.workout else {return false}
        let endTime = Date()
        let duration = getTimeDifference(startDate: startTime, endDate: endTime)        /// Calculate the workout duration
        workout.duration = duration
        await recordWorkout(workout)                                                    /// Save this workout
        return true
    }
    
    func resetTimer() async {
        guard isTimerRunning else {return}
        isTimerRunning = false
        startTime = nil
        workout = nil
    }
    
    @MainActor
    public func displayExercises(_ exercises: [Exercise]) {
        self.exercies = exercises
    }
}
