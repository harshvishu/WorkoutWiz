//
//  ListWorkoutIOPort.swift
//  
//
//  Created by harsh vishwakarma on 23/12/23.
//

import Foundation

public protocol ListWorkoutIOPort: AnyObject {
    func listWorkouts() async throws -> [WorkoutRecord]
}
