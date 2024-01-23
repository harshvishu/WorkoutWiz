//
//  ApplicationMessage.swift
//  
//
//  Created by harsh vishwakarma on 29/12/23.
//
import Domain

public enum ApplicationMessage {
    case workoutFinished
    case openEditWorkoutSheet
    case openWorkout(WorkoutRecord)
    case closeWorkoutEditor
    case showLogs
    case showKeypadForTime
}
