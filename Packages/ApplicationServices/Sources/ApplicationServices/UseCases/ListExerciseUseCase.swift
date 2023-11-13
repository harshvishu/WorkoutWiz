//
//  ListExerciseUseCase.swift
//  
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain

public final class ListExerciseUseCase: ListExerciseInputPort {
    public weak var output: ListExerciseOutputPort?
    var exerciseRepository: ExerciseRepository
    
    public init(output: ListExerciseOutputPort? = nil, exerciseRepository: ExerciseRepository) {
        self.output = output
        self.exerciseRepository = exerciseRepository
    }

    public func listExercise() async {
        let exercises = await exerciseRepository.fetchExercises()
        output?.displayExercises(exercises)
    }
}
