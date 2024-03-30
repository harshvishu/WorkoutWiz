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
    public var sortOrder: Int = 0
        
    @Relationship(deleteRule: .cascade, inverse: \Rep.exercise) private var _reps: [Rep] = []
    public var reps: [Rep] {
        _reps.sorted(using: KeyPathComparator(\Rep.sortOrder))
    }
    
    public var calories: Double = 0.0
    public var maxWeightLifted: Double? // Not needed for ody weight exercises
    
    private var _repCountUnit: Int = RepCountUnit.rep.rawValue
    public var repCountUnit: RepCountUnit {
        set {_repCountUnit = newValue.rawValue}
        get {RepCountUnit(rawValue: _repCountUnit) ?? .rep}
    }
    
    public var isBodyWeightOnly: Bool {
        template?.equipment == .bodyOnly
    }  
    
    public var preferredRepCountUnit: RepCountUnit {
        template?.preferredRepCountUnit() ?? .rep
    }

    public init() {}
    
    // MARK: Public Methods
    public func appendRep(_ rep: Rep) {
        var tempArray = reps
        rep.sortOrder = tempArray.count
        tempArray.append(rep)
        _reps = tempArray
    }
    
    public func deleteRep(rep: Rep) {
        _reps.removeAll { $0 == rep }
    }
    
    public func deleteRep(fromOffsets: IndexSet) {
        var tempArray = reps
        tempArray.remove(atOffsets: fromOffsets)
        setReps(orderedReps: tempArray)
    }
    
    public func setReps(orderedReps: [Rep]) {
        for (index, rep) in orderedReps.enumerated() {
            rep.sortOrder = index
        }
        _reps = orderedReps
    }
    
    public func moveRep(fromOffsets: IndexSet, toOffset: Int) {
        var tempArray = reps
        tempArray.move(fromOffsets: fromOffsets, toOffset: toOffset)
        setReps(orderedReps: tempArray)
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
