//
//  Exercise.swift
//
//
//  Created by harsh vishwakarma on 13/12/23.
//

import Foundation
import SwiftData

@Model
public final class Exercise: Identifiable {
    @Attribute(.unique) public var id: UUID = UUID()
    
    public var template: ExerciseBluePrint?
    public var workout: Workout?
    
    @Relationship(deleteRule: .cascade, inverse: \Rep.exercise)
    public var reps: [Rep] = []
    
    public var calories: Double = 0.0
    public var maxWeightLifted: Double? // Not needed for ody weight exercises
    
    private var _repCountUnit: Int = RepCountUnit.rep.rawValue
   
    public init() {}
    
    public var repCountUnit: RepCountUnit {
        set {
            self._repCountUnit = newValue.rawValue
        }
        get {
            RepCountUnit(rawValue: _repCountUnit) ?? .rep
        }
    }
    
    public var isBodyWeightOnly: Bool {
        template?.equipment == .bodyOnly
    }  
    
    public func preferredRepCountUnit() -> RepCountUnit {
        template?.preferredRepCountUnit() ?? .rep
    }
}

extension Exercise: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

public extension Exercise {
    static func estimatedCaloriesBurned(reps: [Rep]) -> Double {
        return reps.reduce(0.0) {$0 + $1.calories }
    }
    
    static func abbreviatedMuscle(exercises: [Exercise]) -> ExerciseMuscles? {
        let wordCounts = exercises
            .flatMap({$0.template?.primaryMuscles ?? [ExerciseMuscles.none]})
            .reduce(into: [:]) { counts, word in
                counts[word, default: 0] += 1
            }
        return wordCounts.max { $0.value < $1.value }?.key
    }
    
    static func getMaxWeightLifted(reps:  [Rep]) -> Double {
        reps.max(by: {$0.weight < $1.weight})?.weight ?? 0.0
    }
}
