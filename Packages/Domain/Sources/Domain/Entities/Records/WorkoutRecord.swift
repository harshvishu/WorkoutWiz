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
    public var name: String?
    public var startDate: Date?
    public var endDate: Date?
    public var duration: TimeInterval?
    public var notes: String?
    public var exercises: [ExerciseRecord]
    
    public init(documentID: String, name: String?, startDate: Date?, endDate: Date?, duration: TimeInterval?, notes: String?, exercises: [ExerciseRecord] = []) {
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
        self.name = nil
        self.startDate = nil
        self.endDate = nil
        self.duration = nil
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
    
    static func mock(_ index: Int = 0) -> Self {
        WorkoutRecord(documentID: "Workout_\(index)", name: "Workout_\(index)", startDate: .distantPast, endDate: .now, duration: nil, notes: "Workout_\(index) Notes", exercises: [
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
