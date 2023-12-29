//
//  SaveDataRecord.swift
//  
//
//  Created by harsh vishwakarma on 18/12/23.
//

import Foundation

/// Use this to save the information on the execise when last performed
/// 
public struct SaveDataRecord {
    public let id: UUID = UUID()
    
    public var documentID: String
    public var date: Date
    public var exerciseName: String
    public var sets: [ExerciseSet]
    
    public init(documentID: String = UUID().uuidString, date: Date = .now, exerciseName: String, sets: [ExerciseSet]) {
        self.documentID = documentID
        self.date = date
        self.exerciseName = exerciseName
        self.sets = sets
    }
}
