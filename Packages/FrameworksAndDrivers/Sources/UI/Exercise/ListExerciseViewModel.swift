//
//  ListExerciseViewModel.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Observation
import Domain
import ApplicationServices

@Observable
public final class ListExerciseViewModel: ListExerciseOutputPort {
    public private(set) var exercies: [Exercise] = []
    
    private let listExerciseUseCase: ListExerciseInputPort
    
    public init(listExerciseUseCase: ListExerciseInputPort) {
        self.listExerciseUseCase = listExerciseUseCase
        (listExerciseUseCase as? ListExerciseUseCase)?.output = self
        print("New list Exersice View Model")
    }
    
    @MainActor
    public func displayExercises(_ exercises: [Exercise]) {
        self.exercies = exercises
    }
    
    func listExercises() async {
        await listExerciseUseCase.listExercise()
    }
}
