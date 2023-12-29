//
//  ExerciseTemplate.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation

public struct ExerciseTemplate: Identifiable, Codable {
    public let id = UUID()
    
    public let name: String
    public let force: String?
    public let level: String?
    public let mechanic: String?
    public let equipment: String?
    public let primaryMuscles: [String]?
    public let secondaryMuscles: [String]?
    public let instructions: [String]?
    public let category: String?
    public var caloricExpenditureFactor: Double?
    
    enum CodingKeys: String, CodingKey {
        case name
        case force
        case level
        case mechanic
        case equipment
        case primaryMuscles
        case secondaryMuscles
        case instructions
        case category
        case caloricExpenditureFactor
    }
    
    public init(documentID: String? = nil, name: String, force: String?, level: String?, mechanic: String?, equipment: String?, primaryMuscles: [String]?, secondaryMuscles: [String]?, instructions: [String]?, category: String?, caloricExpenditureFactor: Double?) {
        self.name = name
        self.force = force
        self.level = level
        self.mechanic = mechanic
        self.equipment = equipment
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
        self.category = category
        self.caloricExpenditureFactor = caloricExpenditureFactor
    }
    
    public init(
        exercise: ExerciseTemplate
    ) {
        self.name = exercise.name
        self.force = exercise.force
        self.level = exercise.level
        self.mechanic = exercise.mechanic
        self.equipment = exercise.equipment
        self.primaryMuscles = exercise.primaryMuscles
        self.secondaryMuscles = exercise.secondaryMuscles
        self.instructions = exercise.instructions
        self.category = exercise.category
        self.caloricExpenditureFactor = exercise.caloricExpenditureFactor
    }
    
}

extension ExerciseTemplate: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

#if DEBUG
public extension ExerciseTemplate {
    static let mock_1: ExerciseTemplate = ExerciseTemplate(name: "3/4 Sit-Up", force: "pull", level: "beginner", mechanic: "compound", equipment: "body only", primaryMuscles: ["abdominals"], secondaryMuscles: [], instructions: [
        "Lie down on the floor and secure your feet. Your legs should be bent at the knees.",
        "Place your hands behind or to the side of your head. You will begin with your back on the ground. This will be your starting position.",
        "Flex your hips and spine to raise your torso toward your knees.",
        "At the top of the contraction your torso should be perpendicular to the ground. Reverse the motion, going only Â¾ of the way down.",
        "Repeat for the recommended amount of repetitions."
    ], category: "strength", caloricExpenditureFactor: 0.05)
}
#endif
