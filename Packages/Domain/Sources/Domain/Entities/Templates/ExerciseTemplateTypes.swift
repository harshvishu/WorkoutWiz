//
//  ExerciseTemplateTypes.swift
//  
//
//  Created by harsh vishwakarma on 03/01/24.
//

import Foundation

public enum ExerciseForce: String, Hashable, Equatable, CaseIterable, Codable {
    case `static` = "static"
    case pull = "pull"
    case push = "push"
}

public enum ExerciseLevel: String, Hashable, Equatable, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case expert = "expert"
}

public enum ExerciseMechanic: String, Hashable, Equatable, CaseIterable, Codable {
    case isolation = "isolation"
    case compound = "compound"
}

public enum ExerciseEquipment: String, Hashable, Equatable, CaseIterable, Codable {
    case medicineBall = "medicine ball"
    case dumbbell = "dumbbell"
    case bodyOnly = "body only"
    case bands = "bands"
    case kettlebells = "kettlebells"
    case foamRoll = "foam roll"
    case cable = "cable"
    case machine = "machine"
    case barbell = "barbell"
    case exerciseBall = "exercise ball"
    case ezCurlBar = "e-z curl bar"
    case other = "other"
}

public enum ExerciseMuscles: String, Hashable, Equatable, CaseIterable, Codable {
    case abdominals = "abdominals"
    case abductors = "abductors"
    case adductors = "adductors"
    case biceps = "biceps"
    case calves = "calves"
    case chest = "chest"
    case forearms = "forearms"
    case glutes = "glutes"
    case hamstrings = "hamstrings"
    case lats = "lats"
    case lowerBack = "lower back"
    case middleBack = "middle back"
    case neck = "neck"
    case quadriceps = "quadriceps"
    case shoulders = "shoulders"
    case traps = "traps"
    case triceps = "triceps"
    case none = "none"
}

public enum ExerciseCategory: String, Hashable, Equatable, CaseIterable, Codable {
    case powerlifting = "powerlifting"
    case strength = "strength"
    case stretching = "stretching"
    case cardio = "cardio"
    case olympicWeightlifting = "olympic weightlifting"
    case strongman = "strongman"
    case plyometrics = "plyometrics"
    case none = "none"
}

public extension ExerciseCategory {
    func met(vigorous: Bool = false) -> Double {
        switch self {
        case .powerlifting, .strongman, .strength, .none:
            vigorous ? 6 : 3.5
        case .stretching:
            vigorous ? 2.8 : 2.3
        case .cardio:
            vigorous ? 6 : 4
        case .olympicWeightlifting:
            6
        case .plyometrics:
            vigorous ? 8 : 3.8
        }
    }
    
    func iconForCategory() -> String {
        switch self {
        case .cardio:
            "figure.mixed.cardio"
        case .stretching:
            "figure.cooldown"
        case .olympicWeightlifting:
            "dumbbell"
        case .plyometrics:
            "figure.track.and.field"
        case .strength, .powerlifting, .strongman, .none:
            "figure.strengthtraining.traditional"
        }
    }
}
