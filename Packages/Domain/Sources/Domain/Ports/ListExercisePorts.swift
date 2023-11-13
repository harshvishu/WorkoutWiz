//
//  ListExerciseUseCase.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation

public protocol ListExerciseOutputPort: AnyObject {
    func displayExercises(_ exercises: [Exercise])
}

public protocol ListExerciseInputPort {
    func listExercise() async
}
