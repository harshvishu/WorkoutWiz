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
    
    @Relationship(deleteRule: .cascade, inverse: \Exercise.workout) private var _exercises: [Exercise] = []
    public var exercises: [Exercise] {
        _exercises.sorted(using: KeyPathComparator(\Exercise.sortOrder))
    }
    
    private var _abbreviatedMuscle: String = ExerciseMuscles.none.rawValue
    public var abbreviatedMuscle: ExerciseMuscles {
        get {
            ExerciseMuscles(rawValue: _abbreviatedMuscle) ?? .none
        }
        set {
            _abbreviatedMuscle = newValue.rawValue
        }
    }
    
    private var _abbreviatedCategory: String = ExerciseCategory.none.rawValue
    public var abbreviatedCategory: ExerciseCategory {
        get {
            ExerciseCategory(rawValue: _abbreviatedCategory) ?? .none
        }
        set {
            _abbreviatedCategory = newValue.rawValue
        }
    }
  
    public init(){}
    
    // MARK: Public Methods
    public func appendExercise(_ exercise: Exercise) {
        var tempArray = exercises
        exercise.sortOrder = tempArray.count
        tempArray.append(exercise)
        _exercises = tempArray
    }
    
    public func deleteExercise(exercise: Exercise) {
        _exercises.removeAll { $0 == exercise }
    }
    
    public func deleteExercise(fromOffsets: IndexSet) {
        var tempArray = exercises
        tempArray.remove(atOffsets: fromOffsets)
        setExercise(orderedExercises: tempArray)
    }
    
    public func setExercise(orderedExercises: [Exercise]) {
        for (index, exercise) in orderedExercises.enumerated() {
            exercise.sortOrder = index
        }
        _exercises = orderedExercises
    }
    
    public func moveExercise(fromOffsets: IndexSet, toOffset: Int) {
        var tempArray = exercises
        tempArray.move(fromOffsets: fromOffsets, toOffset: toOffset)
        setExercise(orderedExercises: tempArray)
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
