//
//  ListExerciseUseCase.swift
//  
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain

public final class ListExerciseUseCase: ListExerciseIOPort {
    var exerciseRepository: ExerciseRepository
    
    public init(exerciseRepository: ExerciseRepository) {
        self.exerciseRepository = exerciseRepository
    }

    public func listExercise() async -> [ExerciseTemplate]{
        await exerciseRepository.fetchExercises()
    }
}
