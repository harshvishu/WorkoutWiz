//
//  ApplicationMessage.swift
//  
//
//  Created by harsh vishwakarma on 29/12/23.
//
import Domain
import Foundation

public enum ApplicationMessage {
    case workoutFinished
    case openEditWorkoutSheet
    case openWorkout(Workout)
    case closeWorkoutEditor
    case showLogs
    case showKeypadForTime
    case updateSet(Rep)
    case popup(PopupMessage)
    case addSetToExercise(set: Rep, exercise: Exercise)
}

public enum PopupMessage: Equatable {
    case addSetToExercise(Exercise)
    case editSetForExercise(Exercise, Rep)
}
