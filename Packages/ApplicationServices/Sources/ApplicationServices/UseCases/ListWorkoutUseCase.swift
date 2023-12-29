//
//  ListWorkoutUseCase.swift
//  
//
//  Created by harsh vishwakarma on 23/12/23.
//

import Foundation
import Domain
import OSLog

public final class ListWorkoutUseCase: ListWorkoutIOPort {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ListWorkoutUseCase.self))
    
    var workoutRepository: WorkoutRepository
    
    public init(workoutRepository: WorkoutRepository) {
        self.workoutRepository = workoutRepository
    }
    
    public func listWorkouts() async throws -> [WorkoutRecord] {
        try await workoutRepository.fetchWorkouts()
    }
    
}

