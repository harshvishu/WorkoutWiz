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

public final class UserDefaultsExerciseTemplateRepository: ExerciseRepository {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: UserDefaultsExerciseTemplateRepository.self))

    public init() {}
    
    public func fetchExercises() async -> [Domain.ExerciseTemplate] {
        // TODO: Must Call SwiftData
        let exersices = await readJSONFromBundle()
        return exersices
    }
}

fileprivate extension UserDefaultsExerciseTemplateRepository {
    func readJSONFromBundle() async -> [ExerciseTemplate] {
        let data = Bundle.module.decode([ExerciseTemplate].self, forResource: "exercises", withExtension: "json")
        logger.debug("\(data)")
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
