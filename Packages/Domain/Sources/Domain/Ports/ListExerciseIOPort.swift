//
//  ListExerciseIOPort.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation

public protocol ListExerciseIOPort {
    func listExercise() async -> [ExerciseTemplate]
    func imageUrlFor(exercise: ExerciseTemplate) -> [URL]
    func fetchExercise(forID id: String) async -> ExerciseTemplate?
    func url(forImageName imageName: String) -> URL
}
