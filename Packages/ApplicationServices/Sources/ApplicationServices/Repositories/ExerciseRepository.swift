//
//  ExerciseRepository.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain

public protocol ExerciseRepository {
    func fetchExercises() async -> [ExerciseTemplate]
    func fetchExercise(forID id: String) async -> ExerciseTemplate?
    var imageBaseURL: URL {get}
}
