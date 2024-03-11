//
//  WorkoutDatabase.swift
//  
//
//  Created by harsh vishwakarma on 07/03/24.
//

import ComposableArchitecture
import Domain
import SwiftData
import Foundation

// MARK: Wokrout Database
public extension DependencyValues {
    var workoutDatabase: WorkoutDatabase {
        get{self[WorkoutDatabase.self]}
        set{self[WorkoutDatabase.self] = newValue}
    }
}

public struct WorkoutDatabase {
    public var fetchAll: @Sendable () throws -> [Workout]
    public var fetch: @Sendable (FetchDescriptor<Workout>) throws -> [Workout]
    public var add: @Sendable (Workout) throws -> Void
    public var delete: @Sendable (Workout) throws -> Void
    
    enum WorkoutError: Error {
        case add
        case delete
    }
}

extension WorkoutDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = try databaseService.context()
                
                let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\Workout.startDate, order: .reverse)])
                return try databaseContext.fetch(descriptor)
            } catch {
                print(error)
                return []
            }
        }, fetch: { descriptor in
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = try databaseService.context()

                return try databaseContext.fetch(descriptor)
            } catch {
                print(error)
                return []
            }
        }, add: { model in
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = try databaseService.context()
                
                databaseContext.insert(model)
                
            } catch {
                throw WorkoutError.add
            }
        }, delete: { model in
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = try databaseService.context()
                
                databaseContext.delete(model)
            } catch {
                throw WorkoutError.delete
            }
        }
    )
}

extension WorkoutDatabase: TestDependencyKey {
    public static var previewValue = Self {
        [.mock]
    } fetch: { _ in
        [.mock]
    } add: { _ in
        
    } delete: { _ in
        
    }
}

// MARK: - Mock data

public extension Workout {
  static let mock = Workout()
}
