//
//  Rep.swift
//
//
//  Created by harsh vishwakarma on 18/12/23.
//

import Foundation
import SwiftData
import SwiftUI

@Model
public final class Rep: Identifiable {
    @Attribute(.unique) public var id: UUID = UUID()
    
    public var exercise: Exercise?
    
    public var weight: Double
    public var time: TimeInterval
    public var count: Int
    public var calories: Double
    public var sortOrder: Int = 0
    
    private var _weightUnit: Int
    private var _countUnit: Int
    private var _repType: Int
    
    public init(weight: Double, countUnit: RepCountUnit, time: TimeInterval, count: Int, weightUnit: WeightUnit, calories: Double, repType: RepType) {
        self.weight = weight
        self.time = time
        self.count = count
        self.calories = calories
        self._weightUnit = weightUnit.rawValue
        self._countUnit = countUnit.rawValue
        self._repType = repType.rawValue
    }
    
    public var repType: RepType {
        set {
            self._repType = newValue.rawValue
        }
        get {
            RepType(rawValue: _repType) ?? .standard
        }
    }
    
    public var countUnit: RepCountUnit {
        set {
            self._countUnit = newValue.rawValue
        }
        get {
            RepCountUnit(rawValue: _countUnit) ?? .rep
        }
    }
    
    public var weightUnit: WeightUnit {
        set {
            self._weightUnit = newValue.rawValue
        }
        get {
            WeightUnit(rawValue: _weightUnit) ?? .kg
        }
    }
    
    public func isValid() -> Bool {
        return weight > 0 && ( time > 0 || count > 0 )
    }

}

extension Rep: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

public enum RepCountUnit: Int {
    case rep = 0
    case time = 1
    
    public var description: String {
        switch self {
        case .rep: "reps"
        case .time: "time"
        }
    }
}

public enum RepType: Int, CaseIterable {
    
    case standard = 0
    case warmup = 1
    case dropset = 2
    case failure = 3
    
    public var description: String {
        switch self {
        case .standard:
            "Standard"
        case .warmup:
            "Warm Up"
        case .dropset:
            "Drop Set"
        case .failure:
            "Failure"
        }
    }
    
    public var sfSymbol: String {
        switch self {
        case .standard:
            "circle"
        case .warmup:
            "w.circle.fill"
        case .dropset:
            "d.circle.fill"
        case .failure:
            "f.circle.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .standard:
            Color.secondary
        case .warmup:
            Color.green
        case .dropset:
            Color.blue
        case .failure:
            Color.red
        }
    }
}

public enum WeightUnit: Int, Codable, CaseIterable {
    case kg = 0
    case pound = 1
    
    public var sfSymbol: String {
        switch self {
        case .kg: "kg"
        case .pound: "lbs"
        }
    }
}

public enum HeightUnit: Int, Codable, CaseIterable {
    case meter = 0
    case feet = 1
    
    public var sfSymbol: String {
        switch self {
        case .meter: return "m"
        case .feet: return "ft"
        }
    }
}
