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
    var imageBaseURL: URL {get}
}
