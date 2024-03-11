//
//  Workout.swift
//
//
//  Created by harsh vishwakarma on 13/12/23.
//

import Foundation
import SwiftData

@Model
public final class Workout: Identifiable, Equatable {
    @Attribute(.unique) public var id: UUID = UUID()
    
    public var name: String = ""
    public var startDate: Date = Date()
    public var endDate: Date = Date()
    public var duration: TimeInterval = 0.0
    public var notes: String = ""
    public var calories: Double = 0.0
    
    @Relationship(deleteRule: .cascade, inverse: \Exercise.workout)
    public var exercises: [Exercise] = []
    
    private var abbreviatedMuscleRaw: String = ExerciseMuscles.none.rawValue
    private var abbreviatedCategoryRaw: String = ExerciseCategory.none.rawValue
    
  
    public init(){}
    
    public var abbreviatedMuscle: ExerciseMuscles {
        get {
            ExerciseMuscles(rawValue: abbreviatedMuscleRaw) ?? .none
        }
        set {
            abbreviatedMuscleRaw = newValue.rawValue
        }
    }
    
    public var abbreviatedCategory: ExerciseCategory {
        get {
            ExerciseCategory(rawValue: abbreviatedCategoryRaw) ?? .none
        }
        set {
            abbreviatedCategoryRaw = newValue.rawValue
        }
    }
}

extension Workout: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// TODO: Move it to comply with Architecture pattern
public extension Workout {
    static func estimatedCaloriesBurned(exercises: [Exercise]) -> Double {
        exercises.reduce(0.0, {$0 + $1.calories})
    }
    
    static func abbreviatedCategory(exercises: [Exercise]) -> ExerciseCategory? {
        let wordCounts = exercises.reduce(into: [:]) { counts, word in
            counts[word.template?.category ?? .none, default: 0] += 1
        }
        
        return wordCounts.max { $0.value < $1.value }?.key
    }
    
    static func iconFor(category: ExerciseCategory?) -> String {
        category?.iconForCategory() ?? "figure.core.training"
    }

    static func abbreviatedMuscle(exercises: [Exercise]) -> ExerciseMuscles? {
        let wordCounts = exercises
            .flatMap({$0.template?.primaryMuscles ?? [ExerciseMuscles.none]})
            .reduce(into: [:]) { counts, word in
                counts[word, default: 0] += 1
            }
        return wordCounts.max { $0.value < $1.value }?.key
    }
}

public struct WorkoutSummary {
    public let estimatedCaloriesBurned: Double
    public let abbreviatedCategory: ExerciseCategory?
    public let abbreviatedMuscle: ExerciseMuscles?
    
    public init(exercises: [Exercise]) {
        var caloriesBurned: Double = 0.0
        var categoryCounts: [ExerciseCategory: Int] = [:]
        var muscleCounts: [ExerciseMuscles: Int] = [:]
        
        for exercise in exercises {
            caloriesBurned += exercise.calories
            
            let category = exercise.template?.category ?? ExerciseCategory.none
            categoryCounts[category, default: 0] += 1
            
            let muscles = exercise.template?.primaryMuscles ?? [ExerciseMuscles.none]
            for muscle in muscles {
                muscleCounts[muscle, default: 0] += 1
            }
        }
        
        estimatedCaloriesBurned = caloriesBurned
        abbreviatedCategory = categoryCounts.max { $0.value < $1.value }?.key
        abbreviatedMuscle = muscleCounts.max { $0.value < $1.value }?.key
    }
}
