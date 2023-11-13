//
//  FirebaseExerciseRepository.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain
import ApplicationServices

public final class FirebaseExerciseRepository: ExerciseRepository {
    public init() {}
    
    public func fetchExercises() async -> [Domain.Exercise] {
        // TODO: Must Call Firebase API
        let exersices = [
            Exercise(name: "Chest Press", caloriesPerSecond: 0.025, tags: ["Chest", "Push"]),
            Exercise(name: "Inclined Chest Press", caloriesPerSecond: 0.020, tags: ["Chest", "Push"]),
            Exercise(name: "Declined Chest Press", caloriesPerSecond: 0.015, tags: ["Chest", "Push"]),
            Exercise(name: "Dumbell Press", caloriesPerSecond: 0.010, tags: ["Chest", "Push", "Dumbell"]),
            Exercise(name: "Dumbell Fly", caloriesPerSecond: 0.015, tags: ["Chest", "Push", "Dumbell"]),
        ]
        return exersices
    }
    
}
