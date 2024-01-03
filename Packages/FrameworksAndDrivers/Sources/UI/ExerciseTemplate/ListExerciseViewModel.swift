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
//    private(set) var exercies: [ExerciseTemplate] = []
    
    private let listExerciseUseCase: ListExerciseIOPort
    private var messageQueue: ConcreteMessageQueue<[ExerciseTemplate]>?
    private(set) var viewState: ViewState = .loading
    
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
        let exercies = await listExerciseUseCase.listExercise()
        if exercies.isNotEmpty {
            self.viewState = .display(templates: exercies)
        } else {
            self.viewState = .empty
        }
    }
    
    /// Methods
    func set(messageQueue: ConcreteMessageQueue<[ExerciseTemplate]>?) {
        self.messageQueue = messageQueue
    }
    
    func didSelect(exercises: [ExerciseTemplate]) {
        messageQueue?.send(exercises)
    }
    
    func imageUrlFor(exercise: ExerciseTemplate) -> [URL] {
        listExerciseUseCase.imageUrlFor(exercise: exercise)
    }
}

extension ListExerciseViewModel {
    enum ViewState {
        case loading
        case empty
        case display(templates: [ExerciseTemplate])
    }
}
