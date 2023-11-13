//
//  WorkoutRepository.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain

public protocol WorkoutRepository {
    func recordWorkout(_ workout: Workout) async -> Result<Workout, Error>
}
