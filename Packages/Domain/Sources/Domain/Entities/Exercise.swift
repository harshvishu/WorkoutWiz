//
//  Exercise.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation

//public struct Exercise: Identifiable {
//    public let id: String = UUID().uuidString
//    public let name: String
//    public let caloriesPerSecond: Double
//    public let tags: [String]
//
//    public init(name: String, caloriesPerSecond: Double, tags: [String]) {
//        self.name = name
//        self.caloriesPerSecond = caloriesPerSecond
//        self.tags = tags
//    }
//}

public struct Exercise: Identifiable, Codable {
    public let id: String = UUID().uuidString
    
    public let name: String
    public let force: String?
    public let level: String?
    public let mechanic: String?
    public let equipment: String?
    public let primaryMuscles: [String]?
    public let secondaryMuscles: [String]?
    public let instructions: [String]?
    public let category: String?
    
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
    }
    
    public init(name: String, force: String?, level: String?, mechanic: String?, equipment: String?, primaryMuscles: [String]?, secondaryMuscles: [String]?, instructions: [String]?, category: String?) {
        self.name = name
        self.force = force
        self.level = level
        self.mechanic = mechanic
        self.equipment = equipment
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
        self.category = category
    }
}
