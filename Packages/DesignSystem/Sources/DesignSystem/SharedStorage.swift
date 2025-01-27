//
//  SharedStorage.swift
//  
//
//  Created by harsh vishwakarma on 29/03/24.
//

import SwiftUI
import Combine

@propertyWrapper
public struct SharedStorage<T> {
    
    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults

    
    public init(_ key: String, defaultValue: T, userDefaults: UserDefaults) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
    
    public var wrappedValue: T {
        get {
            if let value = userDefaults.object(forKey: key) as? T {
                return value
            }
            return defaultValue
        }
        set {
            userDefaults.set(newValue, forKey: key)
            userDefaults.synchronize()
            // Notify observers of the change
            NotificationCenter.default.post(name: .userDefaultsValueChanged, object: key)
        }
    }
    
    public var observer: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: .userDefaultsValueChanged)
    }
}

public extension SharedStorage where T: Codable {
    
    var wrappedValue: T {
        get {
            guard let data = userDefaults.data(forKey: key) else {
                return defaultValue
            }
            do {
                let decodedValue = try JSONDecoder().decode(T.self, from: data)
                return decodedValue
            } catch {
                return defaultValue
            }
        }
        set {
            do {
                let encodedValue = try JSONEncoder().encode(newValue)
                userDefaults.set(encodedValue, forKey: key)
                userDefaults.synchronize()
                // Notify observers of the change
                NotificationCenter.default.post(name: .userDefaultsValueChanged, object: key)
            } catch {
                print("Error encoding value for key \(key): \(error)")
            }
        }
    }
}

public extension Notification.Name {
    static let userDefaultsValueChanged = Notification.Name("UserDefaultsValueChanged")
}
