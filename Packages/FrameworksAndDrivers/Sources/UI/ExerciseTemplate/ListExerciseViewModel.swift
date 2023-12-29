//
//  ListExerciseViewModel.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Observation
import Domain
import ApplicationServices
import Persistence
import DesignSystem
import Combine

@Observable
public final class ListExerciseViewModel {
    public private(set) var exercies: [ExerciseTemplate] = []
    
    private let listExerciseUseCase: ListExerciseIOPort
    private var messageQueue: ConcreteMessageQueue<[ExerciseTemplate]>?
    
    public init(
        listExerciseUseCase: ListExerciseIOPort = ListExerciseUseCase(
            exerciseRepository: UserDefaultsExerciseTemplateRepository()
        ),
        messageQueue: ConcreteMessageQueue<[ExerciseTemplate]>? = nil
    ) {
        self.listExerciseUseCase = listExerciseUseCase
        self.messageQueue = messageQueue
    }
    
    func listExercises() async {
        self.exercies = await listExerciseUseCase.listExercise()
    }
    
    /// Methods
    func set(messageQueue: ConcreteMessageQueue<[ExerciseTemplate]>?) {
        self.messageQueue = messageQueue
    }
    
    func didSelect(exercises: [ExerciseTemplate]) {
        messageQueue?.send(exercises)
    }
}
