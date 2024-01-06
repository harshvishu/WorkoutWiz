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
        self.documentID = UUID().uuidString
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
                .init(weight: 5, rep: 12),
                .init(weight: 7.5, rep: 10),
                .init(weight: 12.5, rep: 8)
            ]),
            ExerciseRecord(documentID: "Workout_Exercise_2_\(index)", template: .mock_1, sets: [
                .init(weight: 135, rep: 10),
                .init(weight: 175, rep: 6),
                .init(weight: 200, rep: 4)
            ])
        ])
    }
}
#endif
