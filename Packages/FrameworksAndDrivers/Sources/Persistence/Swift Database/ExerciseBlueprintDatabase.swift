//
//  ExerciseBluePrint.swift
//  
//
//  Created by harsh vishwakarma on 07/03/24.
//

import ComposableArchitecture
import Domain
import SwiftData
import Foundation

// MARK: ExerciseBluePrint Database
public extension DependencyValues {
    var exerciseBluePrintDatabase: ExerciseBlueprintDatabase {
        get{self[ExerciseBlueprintDatabase.self]}
        set{self[ExerciseBlueprintDatabase.self] = newValue}
    }
}

public struct ExerciseBlueprintDatabase {
    public var fetchAll: @Sendable () throws -> [ExerciseBluePrint]
    public var fetch: @Sendable (FetchDescriptor<ExerciseBluePrint>) throws -> [ExerciseBluePrint]
}

extension ExerciseBlueprintDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = try databaseService.context()
                
                let descriptor = FetchDescriptor<ExerciseBluePrint>(sortBy: [SortDescriptor(\ExerciseBluePrint.name)])
                return try databaseContext.fetch(descriptor)
            } catch {
                print(error)
                return []
            }
        }, fetch: { descriptor in
            do {
                @Dependency(\.databaseService.context) var context
                let databaseContext = try context()
                
                return try databaseContext.fetch(descriptor)
            } catch {
                print(error)
                return []
            }
        }
    )
}
