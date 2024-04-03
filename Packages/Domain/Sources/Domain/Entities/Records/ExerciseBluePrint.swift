//
//  ExerciseBluePrint.swift
//  
//
//  Created by harsh vishwakarma on 15/02/24.
//

import Foundation
import SwiftData

@Model
public final class ExerciseBluePrint: Identifiable, Hashable {
    @Attribute(.unique) public let id: String
    
    // Template properties
    public var name: String
    public var instructions: [String]
    public var images: [String]
    private var _force: String?
    private var _level: String
    private var _mechanic: String?
    private var _equipment: String?
    private var _primaryMuscles: [String]
    private var _secondaryMuscles: [String]
    private var _category: String
    
    // Dynamic Properties
    public var frequency: Int = 0   // higher frequency gives priority in search results
    public var searchString: String = ""
         
    public init(id: String, name: String, force: ExerciseForce?, level: ExerciseLevel, mechanic: ExerciseMechanic?, equipment: ExerciseEquipment?, primaryMuscles: [ExerciseMuscles], secondaryMuscles: [ExerciseMuscles], instructions: [String], category: ExerciseCategory, images: [String]) {
        self.id = id
        self.name = name
        self.instructions = instructions
        self.images = images
        self._force = force?.rawValue
        self._level = level.rawValue
        self._mechanic = mechanic?.rawValue
        self._equipment = equipment?.rawValue
        self._primaryMuscles = primaryMuscles.map(\.rawValue)
        self._secondaryMuscles = secondaryMuscles.map(\.rawValue)
        self._category = category.rawValue
    }
    
    @Transient
    public var force: ExerciseForce? {
        get {
            guard let _force = _force else {return nil}
            return ExerciseForce(rawValue: _force)
        }
    }
    
    @Transient
    public var level: ExerciseLevel {
        get {
            return ExerciseLevel(rawValue: _level) ?? .beginner
        }
    }
    
    @Transient
    public var mechanic: ExerciseMechanic? {
        get {
            guard let _mechanic = _mechanic else {return nil}
            return ExerciseMechanic(rawValue: _mechanic)
        }
    }
    
    @Transient
    public var equipment: ExerciseEquipment? {
        get {
            guard let _equipment = _equipment else {return nil}
            return ExerciseEquipment(rawValue: _equipment)
        }
    }
    
    @Transient
    public var primaryMuscles: [ExerciseMuscles] {
        get {
            _primaryMuscles.compactMap({ ExerciseMuscles(rawValue: $0) })
        }
    }
    
    @Transient
    public var secondaryMuscles: [ExerciseMuscles] {
        get {
            _secondaryMuscles.compactMap({ ExerciseMuscles(rawValue: $0) })
        }
    }
    
    @Transient
    public var category: ExerciseCategory {
        get {
            ExerciseCategory(rawValue: _category) ?? .none
        }
    }
    
    @Transient
    public var isBodyWeightOnly: Bool {
        equipment == .bodyOnly
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

public extension ExerciseBluePrint {
    func abbreviatedMuscle() ->  ExerciseMuscles? {
        let wordCounts = primaryMuscles
            .reduce(into: [:]) { counts, word in
                counts[word, default: 0] += 1
            }
        
        return wordCounts.max { $0.value < $1.value }?.key
    }
    
    func preferredRepCountUnit() -> RepCountUnit {
        (force == nil || mechanic == nil) ? .time : .rep
    }
}
