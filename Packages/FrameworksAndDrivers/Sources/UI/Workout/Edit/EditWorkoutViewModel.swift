//
//  EditWorkoutViewModel.swift
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
import SwiftData
import OSLog

@Observable
public final class EditWorkoutViewModel {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: EditWorkoutViewModel.self))
    
    var recordWorkoutUseCase: RecordWorkoutIOPort?
    var listExerciseUseCase: ListExerciseIOPort?
        
    public private(set) var isTimerRunning: Bool = false
    public private(set) var startTime: Date? = nil
    public var workout: WorkoutRecord
    
    public init(
        recordWorkoutUseCase: RecordWorkoutIOPort? = nil,
        listExerciseUseCase: ListExerciseIOPort = ListExerciseUseCase(exerciseRepository: UserDefaultsExerciseTemplateRepository())
    ) {
        self.recordWorkoutUseCase = recordWorkoutUseCase
        self.listExerciseUseCase = listExerciseUseCase
        self.workout = WorkoutRecord.empty()    // Start with an empty
    }
    
    public func bind(recordWorkoutUseCase: RecordWorkoutUseCase) {
        logger.info("ViewModel properties set: saveDataInputPort, recordWorkoutUseCase")
        self.recordWorkoutUseCase = recordWorkoutUseCase
    }
    
    // MARK: - Workout
    private func recordWorkout() async {
        do {
            _ = try await recordWorkoutUseCase?.recordWorkout(workout)
            logger.error("Workout saved")
        } catch RecordWorkoutError.writeFailed {
            logger.error("Failed to write workout to db")
        } catch {
            logger.error("\(error)")
        }
    }
    
    func add(exercise: ExerciseTemplate) async {
        await startTimer()
        workout.exercises.append(ExerciseRecord(template: exercise))
    }
    
    func add(exerciesToWorkout exercises: [ExerciseTemplate]) async {
        await startTimer()
        workout.exercises.append(contentsOf: exercises.map({ExerciseRecord(template: $0)}))
    }
    
    func addSetToExercise(withID id: UUID, set: ExerciseSet) {
        guard let index = workout.exercises.firstIndex(where: {$0.id == id}) else {return}
        workout.exercises[index].addSet(set: set)
    }
    
    var isWorkoutComplete: Bool {
        workout.exercises.isNotEmpty
    }
    
    // MARK: - Timer
    func startTimer() async {
        guard !isTimerRunning else {return}
        isTimerRunning = true
        startTime = Date()
        workout.startDate = startTime
    }
    
    func stopTimer() async {
        isTimerRunning = false
    }
    
    func discardWorkout() async {
        isTimerRunning = false
        startTime = nil
        workout = WorkoutRecord.empty()  /// Reset with empty workout
    }
    
    func finishWorkout() async -> Bool {
        guard isTimerRunning,
              let startTime = self.startTime
        else {
            return false
        }
        
        let endTime = Date()
        let duration = getTimeDifference(startDate: startTime, endDate: endTime)    /// Calculate the workout duration
        workout.duration = duration
        workout.endDate = endTime
        await recordWorkout()    /// Save this workout

        self.isTimerRunning = false
        return true
    }
    
    func startEmptyWorkout() {
        guard !isTimerRunning else {return}
        
        self.startTime = nil
        self.workout = WorkoutRecord.empty()  /// Reset with empty workout
    }
    
}

// MARK: - Helper Functions
public extension EditWorkoutViewModel {
    var elapsedTime: ElapsedTime? {
        guard let startTime = startTime else {return nil}
        let timeInterval = getTimeDifference(startDate: startTime, endDate: Date())
        let elapsedTime = ElapsedTime(timeInterval: timeInterval)
        return elapsedTime
    }
    
    var totalCaloriesBurned: Double {
        workout.exercises.reduce(0.0, { $0 + $1.estimatedCaloriesBurned()})
    }
}

public struct ElapsedTime {
    public private(set) var hours: Int
    public private(set) var minutes: Int
    public private(set) var seconds: Int
    public private(set) var milliseconds: Int

    init(timeInterval: TimeInterval) {
        let totalMilliseconds = Int(timeInterval * 1000)
        
        // Calculate hours
        self.hours = totalMilliseconds / (1000 * 60 * 60)
        
        // Calculate remaining minutes
        let remainingMillisecondsInHour = totalMilliseconds % (1000 * 60 * 60)
        self.minutes = remainingMillisecondsInHour / (1000 * 60)
        
        // Calculate remaining seconds
        let remainingMillisecondsInMinute = totalMilliseconds % (1000 * 60)
        self.seconds = remainingMillisecondsInMinute / 1000
        
        // Calculate remaining milliseconds
        self.milliseconds = (totalMilliseconds % 1000) / 100
    }
}
