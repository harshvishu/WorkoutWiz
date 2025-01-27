//
//  SaveDataManager.swift
//  
//
//  Created by harsh vishwakarma on 29/03/24.
//

import ComposableArchitecture
import Domain
import Foundation

let suiteName = "group." + (Bundle.main.bundleIdentifier ?? "") + ".SharedStorage"
let sharedDefaults = UserDefaults(suiteName: suiteName) ?? .standard

public final class SaveDataManager {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public func save<T: Codable>(_ value: T, forKey key: String) {
        userDefaults.saveCodable(value, forKey: key)
    }
    
    public func load<T: Codable>(forKey key: String) -> T? {
        userDefaults.retrieveCodable(forKey: key)
    }
}

public extension DependencyValues {
    var saveData: SaveDataManager {
        get{self[SaveDataManager.self]}
        set{self[SaveDataManager.self] = newValue}
    }
}

extension SaveDataManager: DependencyKey {
    public static var liveValue: SaveDataManager = .init(userDefaults: sharedDefaults)
    public static var previewValue: SaveDataManager = .init(userDefaults: .standard)
}

public extension SaveDataManager {
    struct Keys {
        
    }
}
