//
//  UserDefaultsExtensions.swift
//  
//
//  Created by harsh vishwakarma on 30/03/24.
//

import Foundation

public extension UserDefaults {
    func saveCodable<T: Codable>(_ value: T, forKey key: String) {
        do {
            let encodedData = try JSONEncoder().encode(value)
            self.set(encodedData, forKey: key)
        } catch {
            print("Failed to encode and save \(T.self) with key \(key). Error: \(error)")
        }
    }
    
    func retrieveCodable<T: Codable>(forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else {
            return nil
        }
        do {
            let decodedValue = try JSONDecoder().decode(T.self, from: data)
            return decodedValue
        } catch {
            print("Failed to decode and retrieve \(T.self) with key \(key). Error: \(error)")
            return nil
        }
    }
}
