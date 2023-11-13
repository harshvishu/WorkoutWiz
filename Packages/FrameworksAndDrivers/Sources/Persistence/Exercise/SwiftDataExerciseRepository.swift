//
//  SwiftDataExerciseRepository.swift
//  
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain
import ApplicationServices

public final class SwiftDataExerciseRepository: ExerciseRepository {
    public init() {}
    
    public func fetchExercises() async -> [Domain.Exercise] {
        // TODO: Must Call SwiftData
        let exersices = [
            Exercise(name: "Lat Pull Down", caloriesPerSecond: 0.025, tags: ["Back", "Pull"]),
            Exercise(name: "Cable Row (Close Grip)", caloriesPerSecond: 0.020, tags: ["Back", "Pull"]),
            Exercise(name: "Cable Row (Zig Zag) ", caloriesPerSecond: 0.015, tags: ["Back", "Pull"]),
            Exercise(name: "Dead Lift", caloriesPerSecond: 0.30, tags: ["Back", "Pull", "Dumbell"]),
            Exercise(name: "One Arm Dumbell Row", caloriesPerSecond: 0.015, tags: ["Back", "Pull", "Lats", "Dumbell"]),
        ]
        return exersices
    }
    
}

