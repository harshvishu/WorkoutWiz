//
//  ExerciseRecord.swift
//
//
//  Created by harsh vishwakarma on 13/12/23.
//

import Foundation

public struct ExerciseRecord: Identifiable, Codable {
    public let id = UUID()
    
    public var documentID: String
    public var template: ExerciseTemplate
    public var sets: [ExerciseSet]
    
    enum CodingKeys: String, CodingKey {
        case documentID
        case template
        case sets
    }
    
    public init(documentID: String = UUID().uuidString, template: ExerciseTemplate, sets: [ExerciseSet] = []) {
        self.documentID = documentID
        self.template = template
        self.sets = sets
    }
    
    public mutating func addSet(set: ExerciseSet) {
        self.sets.append(set)
    }
}

extension ExerciseRecord: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

public extension ExerciseRecord {
    // Calories Burned=(Weight Lifted×Repetitions×Sets)×Caloric Expenditure Factor
    func estimatedCaloriesBurned() -> Double {
        let caloricExpenditureFactor = self.template.caloricExpenditureFactor ?? 0.0
        return sets.reduce(0.0) {$0 + $1.weight * Double($1.rep) * caloricExpenditureFactor }
    }
}

