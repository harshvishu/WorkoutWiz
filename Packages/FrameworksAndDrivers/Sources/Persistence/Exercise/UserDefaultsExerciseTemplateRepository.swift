//
//  UserDefaultsExerciseTemplateRepository.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Foundation
import Domain
import ApplicationServices
import OSLog

class StructWrapper<T>: NSObject {

    let value: T

    init(_ _struct: T) {
        self.value = _struct
    }
}

public final class UserDefaultsExerciseTemplateRepository: ExerciseRepository {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: UserDefaultsExerciseTemplateRepository.self))
    
    public let imageBaseURL: URL = URL(string: "https://raw.githubusercontent.com/harshvishu/free-exercise-db/main/exercises/")!

    // private properties
    private var cache = NSCache<NSString, StructWrapper<ExerciseTemplate>>()
    
    public init() {}
    
    public func fetchExercises() async -> [Domain.ExerciseTemplate] {
        let exersices = await readJSONFromBundle()
//        Task(priority: .background) {
//            for exercise in exersices {
//                cache.setObject(StructWrapper(exercise), forKey: NSString(string: exercise.id))
//            }
//        }
        return exersices
    }
    
    public func fetchExercise(forID id: String) async -> ExerciseTemplate? {
        let key = NSString(string: id)
        if let cachedVersion = cache.object(forKey: key) {
            // use the cached version
            return cachedVersion.value
        } else {
            // create it from scratch then store in the cache
            let allExercises = await fetchExercises()
            if let exercise = allExercises.first(where: {$0.id == id}) {
                let wrappedVersion = StructWrapper(exercise)
                cache.setObject(wrappedVersion, forKey: key)
                return exercise
            }
        }
        return nil
    }
}

fileprivate extension UserDefaultsExerciseTemplateRepository {
    func readJSONFromBundle() async -> [ExerciseTemplate] {
        let data = Bundle.module.decode([ExerciseTemplate].self, forResource: "exercises", withExtension: "json")
//        logger.debug("\(data)")
//        Swift.print(Set(data.compactMap(\.category)))
        return data
    }
}

fileprivate extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, forResource file: String, withExtension ext: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        guard let url = self.url(forResource: file, withExtension: ext) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
