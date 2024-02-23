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
    public var imageBaseURL: URL = URL(string: "")!  // TODO: Pending for firebase
    
    public init() {}
    
    public func fetchExercises() async -> [ExerciseTemplate] {
        // TODO: Must Call Firebase API
        let exersices: [ExerciseTemplate] = []
        return exersices
    }
    
    public func fetchExercise(forID id: String) async -> ExerciseTemplate? {
        return nil
    }
    
}
