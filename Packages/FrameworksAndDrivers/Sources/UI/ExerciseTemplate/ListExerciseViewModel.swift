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
import Foundation

@Observable
public final class ListExerciseViewModel {
    private var allExercies: [ExerciseTemplate] = []
    
    private let listExerciseUseCase: ListExerciseIOPort
    private var messageQueue: ConcreteMessageQueue<[ExerciseBluePrint]>?
        
    public init(
        listExerciseUseCase: ListExerciseIOPort = ListExerciseUseCase(
            exerciseRepository: UserDefaultsExerciseTemplateRepository()
        ),
        messageQueue: ConcreteMessageQueue<[ExerciseBluePrint]>? = nil
    ) {
        self.listExerciseUseCase = listExerciseUseCase
        self.messageQueue = messageQueue
    }
    
    /// Methods
    func set(messageQueue: ConcreteMessageQueue<[ExerciseBluePrint]>?) {
        self.messageQueue = messageQueue
    }
    
    func didSelect(exercises: [ExerciseBluePrint]) {
        messageQueue?.send(exercises)
    }
    
    func imageUrlFor(exercise: ExerciseTemplate) -> [URL] {
        listExerciseUseCase.imageUrlFor(exercise: exercise)
    }
    
    func imageUrlFor(exercise: ExerciseBluePrint) -> [URL] {
        exercise.images.map({listExerciseUseCase.url(forImageName: $0)})
    }
}

extension ListExerciseViewModel {
    enum ViewState {
        case loading
        case empty
        case display(templates: [ExerciseTemplate])
    }
}
