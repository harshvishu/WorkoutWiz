//
//  Exercise.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation

public struct Exercise: Identifiable {
    public let id: String = UUID().uuidString
    public let name: String
    public let caloriesPerSecond: Double
    public let tags: [String]
    
    public init(name: String, caloriesPerSecond: Double, tags: [String]) {
        self.name = name
        self.caloriesPerSecond = caloriesPerSecond
        self.tags = tags
    }
}
