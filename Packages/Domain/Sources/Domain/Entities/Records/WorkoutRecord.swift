//
//  WorkoutRecord.swift
//
//
//  Created by harsh vishwakarma on 13/12/23.
//

import Foundation

public struct WorkoutRecord {
    public let id = UUID()
    public var documentID: String
    public var name: String
    public var startDate: Date
    public var endDate: Date
    public var duration: TimeInterval
    public var notes: String?
    public var exercises: [ExerciseRecord]
    
    public init(documentID: String, name: String, startDate: Date, endDate: Date, duration: TimeInterval, notes: String?, exercises: [ExerciseRecord] = []) {
        self.documentID = documentID
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.notes = notes
        self.exercises = exercises
    }
    
    public init() {
        self.documentID = UUID().uuidString // TODO: improve 
        self.name = ""
        self.startDate = .now
        self.endDate = .now
        self.duration = 0
        self.notes = nil
        self.exercises = []
    }
}

extension WorkoutRecord: Identifiable, Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension WorkoutRecord {
    static func empty() -> Self {
        WorkoutRecord()
    }
    
    // Calories Burned=(Weight Lifted×Repetitions×Sets)×Caloric Expenditure Factor
    func estimatedCaloriesBurned() -> Double {
        exercises.reduce(0.0, {$0 + $1.estimatedCaloriesBurned()})
    }
    
    // TODO: Make it better
    func abbreviatedCategory() -> ExerciseCategory? {
        let wordCounts = exercises.reduce(into: [:]) { counts, word in
            counts[word.template.category, default: 0] += 1
        }
        
        return wordCounts.max { $0.value < $1.value }?.key
    }
    
    func iconForCategory() -> String {
        abbreviatedCategory()?.iconForCategory() ?? "figure.core.training"
    }
    
    func abbreviatedMuscle() ->  ExerciseMuscles? {
        let wordCounts = exercises
            .flatMap({$0.template.primaryMuscles})
            .reduce(into: [:]) { counts, word in
                counts[word, default: 0] += 1
            }
        
        return wordCounts.max { $0.value < $1.value }?.key
    }
}

#if DEBUG
public extension WorkoutRecord {
    static func mock(_ index: Int = 0) -> Self {
        WorkoutRecord(documentID: "Workout_\(index)", name: "Workout \(index)", startDate: .distantPast, endDate: .now, duration: 60 * 45, notes: "Workout_\(index) Notes", exercises: [
            ExerciseRecord(documentID: "Workout_Exercise_1_\(index)", template: .mock_1, sets: [
                .init(exerciseID: UUID(), weight: 5, type: .rep, duration: 0.0, rep: 12, calories: 100),
                .init(exerciseID: UUID(), weight: 7.5, type: .rep, duration: 0.0, rep: 10, calories: 10),
                .init(exerciseID: UUID(), weight: 12.5, type: .duration, duration: 60, rep: 0, calories: 2.5)
            ]),
            ExerciseRecord(documentID: "Workout_Exercise_2_\(index)", template: .mock_1, sets: [
                .init(exerciseID: UUID(), weight: 135, type: .rep, duration: 0.0, rep: 10, calories: 3.5),
                .init(exerciseID: UUID(), weight: 175, type: .rep, duration: 0.0, rep: 6, calories: 15.3),
                .init(exerciseID: UUID(), weight: 200, type: .rep, duration: 0.0, rep: 4, calories: 11)
            ])
        ])
    }
}
#endif
