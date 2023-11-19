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
        let exersices: [Exercise] = []
        return exersices
    }
    
}
