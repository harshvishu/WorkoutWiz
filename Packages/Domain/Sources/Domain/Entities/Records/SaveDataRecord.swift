//
//  SaveDataRecord.swift
//  
//
//  Created by harsh vishwakarma on 18/12/23.
//

import Foundation

/// Use this to save the information on the execise when last performed

public struct SaveDataRecord {
    public let id: UUID = UUID()
    
    public var documentID: String
    public var date: Date
    public var exerciseName: String
    public var sets: [Rep]
    
    public init(documentID: String, date: Date = .now, exerciseName: String, sets: [Rep]) {
        self.documentID = documentID
        self.date = date
        self.exerciseName = exerciseName
        self.sets = sets
    }   
    
    public init(date: Date = .now, exerciseName: String, sets: [Rep]) {
        self.documentID = id.uuidString
        self.date = date
        self.exerciseName = exerciseName
        self.sets = sets
    }
}
