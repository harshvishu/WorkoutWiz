//
//  ExerciseTemplatesDatabase.swift
//
//
//  Created by harsh vishwakarma on 07/03/24.
//

import ComposableArchitecture
import Domain
import SwiftData
import Foundation

// MARK: ExerciseTemplate Database
public extension DependencyValues {
    var exerciseTemplatesDatabase: ExerciseTemplatesDatabase {
        get{self[ExerciseTemplatesDatabase.self]}
        set{self[ExerciseTemplatesDatabase.self] = newValue}
    }
}

public struct ExerciseTemplatesDatabase {
    public var fetchAll: @Sendable () throws -> [ExerciseTemplate]
    public var fetch: @Sendable (FetchDescriptor<ExerciseTemplate>) throws -> [ExerciseTemplate]
    public var count: @Sendable (FetchDescriptor<ExerciseTemplate>) throws -> Int
}

extension ExerciseTemplatesDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = databaseService.context()
                
                let descriptor = FetchDescriptor<ExerciseTemplate>(sortBy: [SortDescriptor(\ExerciseTemplate.name)])
                return try databaseContext.fetch(descriptor)
            } catch {
                print(error)
                return []
            }
        }, fetch: { descriptor in
            do {
                @Dependency(\.databaseService.context) var context
                let databaseContext = context()
                
                return try databaseContext.fetch(descriptor)
            } catch {
                print(error)
                return []
            }
        }, count: { descriptor in
            do {
                @Dependency(\.databaseService.context) var context
                let databaseContext = context()
                
                return try databaseContext.fetchCount(descriptor)
            } catch {
                print(error)
                return 0
            }
        }
    )
}
