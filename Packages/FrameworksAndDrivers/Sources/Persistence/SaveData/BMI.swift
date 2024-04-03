//
//  BMI.swift
//  
//
//  Created by harsh vishwakarma on 02/04/24.
//

import Domain
import ComposableArchitecture

public extension DependencyValues {
    var bmi: BMI {
        get{self[BMI.self]}
        set{self[BMI.self] = newValue}
    }
}

public extension BMI {
    func save() {
        @Dependency(\.saveData) var saveData
        return saveData.save(self, forKey: String(describing: BMI.self))
    }
}

extension BMI: DependencyKey {
    public static var liveValue: BMI  {
        @Dependency(\.saveData) var saveData
        return saveData.load(forKey: String(describing: BMI.self)) ?? BMI()
    }
}
