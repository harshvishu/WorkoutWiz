//
//  ListExerciseIOPort.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation

public protocol ListExerciseIOPort {
    func listExercise() async -> [BaseExerciseTemplate]
    func imageUrlFor(exercise: BaseExerciseTemplate) -> [URL]
    func fetchExercise(forID id: String) async -> BaseExerciseTemplate?
    func url(forImageName imageName: String) -> URL
}
