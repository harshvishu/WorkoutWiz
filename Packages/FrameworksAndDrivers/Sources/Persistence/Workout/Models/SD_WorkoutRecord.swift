////
////  SD_WorkoutRecord.swift
////  
////
////  Created by harsh vishwakarma on 06/02/24.
////
//
//import Foundation
//import SwiftData
//import Domain
//
///// MARK: Swift Darta impl for WorkoutRecord
//@Model
//public class SD_WorkoutRecord {
//    @Attribute(.unique) public var id: UUID = UUID()
//    
//    public var name: String
//    public var startDate: Date
//    public var endDate: Date
//    public var time: TimeInterval
//    public var notes: String?
//    public var calories: Double
//    public var abbreviatedMuscle: ExerciseMuscles?
//    public var abbreviatedCategory: ExerciseCategory?
//    
//    @Relationship(deleteRule: .cascade, inverse: \SD_ExerciseRecord.workout)
//    public var exercises: [SD_ExerciseRecord]
//    
//    init(
//        name: String,
//        startDate: Date,
//        endDate: Date,
//        duration: TimeInterval,
//        notes: String? = nil,
//        calories: Double,
//        abbreviatedMuscle: ExerciseMuscles?,
//        abbreviatedCategory: ExerciseCategory?,
//        exercises: [SD_ExerciseRecord]
//    ) {
//        self.name = name
//        self.startDate = startDate
//        self.endDate = endDate
//        self.duration = duration
//        self.notes = notes
//        self.calories = calories
//        self.abbreviatedMuscle = abbreviatedMuscle
//        self.abbreviatedCategory = abbreviatedCategory
//        self.exercises = exercises
//    }
//    
//    public init() {
//        self.name = ""
//        self.startDate = .now
//        self.endDate = .now
//        self.duration = 0
//        self.notes = nil
//        self.calories = 0.0
//        self.abbreviatedMuscle = nil
//        self.abbreviatedCategory = nil
//        self.exercises = []
//    }
//    
//    convenience init(_ record: WorkoutRecord) {
//        self.init(
//            name: record.name,
//            startDate: record.startDate,
//            endDate: record.endDate,
//            duration: record.duration,
//            notes: record.notes,
//            calories: record.calories,
//            abbreviatedMuscle: record.abbreviatedMuscle,
//            abbreviatedCategory: record.abbreviatedCategory,
//            exercises: record.exercises.map({.init(exercise: $0)})
//        )
//    }
//}
//
//extension WorkoutRecord {
//    /// convert Swift Data model into Domain WorkoutRecord
//    init(_ record: SD_WorkoutRecord, exercises: [SD_ExerciseRecord]) {
//        let exercises = exercises.map({ExerciseRecord($0)})
//        
//        self.init(
//            
//            name: record.name,
//            startDate: record.startDate,
//            endDate: record.endDate,
//            duration: record.duration,
//            notes: record.notes,
//            calories: record.calories,
//            abbreviatedMuscle: record.abbreviatedMuscle,
//            abbreviatedCategory: record.abbreviatedCategory,
//            exercises: exercises
//        )
//    }
//}
