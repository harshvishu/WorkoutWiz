//
//  SD_ExerciseRecord.swift
//  
//
//  Created by harsh vishwakarma on 06/02/24.
//

//import Foundation
//import SwiftData
//import Domain
///// MARK: Swift Darta impl for ExerciseRecord
//@Model
//public class SD_ExerciseRecord {
//    @Attribute(.unique) public var id: UUID = UUID()
//    
//    @Attribute(.unique)
//    public var documentID: String?
//    public var template: ExerciseTemplate
//    public var sets: [ExerciseSetRecord]
//    
//    public var workout: SD_WorkoutRecord?
//    
//    public init(documentID: String, template: ExerciseTemplate, sets: [ExerciseSetRecord], workout: SD_WorkoutRecord?) {
//        self.documentID = documentID
//        self.template = template
//        self.sets = sets
//        self.workout = workout
//    }
//    
//    public func addSet(set: ExerciseSetRecord) {
//        self.sets.append(set)
//    }
//}
//
//extension ExerciseRecord {
//    /// convert Swift Data model into Domain ExerciseRecord
//    init(_ record: SD_ExerciseRecord) {
//        self.init(
//            documentID: record.documentID,
//            workoutDocumentID: record.workoutDocumentID,
//            template: record.template,
//            sets: record.sets
//        )
//    }
//}
