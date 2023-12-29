//
//  WorkoutRepository.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain

public protocol WorkoutRepository {
    func recordWorkout(_ workout: WorkoutRecord) async throws -> WorkoutRecord 
    func fetchWorkouts() async throws -> [WorkoutRecord]
}
