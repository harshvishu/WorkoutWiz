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
    public var model: @Sendable (PersistentIdentifier) throws -> Workout?
    public var fetchCount: @Sendable (FetchDescriptor<Workout>) throws -> Int
    public var add: @Sendable (Workout) throws -> Void
    public var delete: @Sendable (Workout) throws -> Void
    public var save: @Sendable () throws -> Void
    public var undo: @Sendable () throws -> Void
    public var undoManager: @Sendable () -> UndoManager?
    
    enum WorkoutError: Error {
        case add
        case delete
        case save
        case undo
    }
}

extension WorkoutDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = databaseService.context()
                
                let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\Workout.startDate, order: .reverse)])
                return try databaseContext.fetch(descriptor)
            } catch {
                print(error)
                return []
            }
        }, fetch: { descriptor in
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = databaseService.context()

                return try databaseContext.fetch(descriptor)
            } catch {
                print(error)
                return []
            }
        }, model: { id in
            @Dependency(\.databaseService) var databaseService
            let databaseContext = databaseService.context()
            
            return databaseContext.registeredModel(for: id)
        }, fetchCount: { descriptor in
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = databaseService.context()

                return try databaseContext.fetchCount(descriptor)
            } catch {
                print(error)
                return 0
            }
        }, add: { model in
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = databaseService.context()
                
                databaseContext.insert(model)
                
            } catch {
                throw WorkoutError.add
            }
        }, delete: { model in
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = databaseService.context()
                
                databaseContext.delete(model)
            } catch {
                throw WorkoutError.delete
            }
        }, save: {
            @Dependency(\.databaseService) var databaseService
            let databaseContext = databaseService.context()
            do { 
                try databaseContext.save()
            } catch {
                throw WorkoutError.save
            }
        }, undo: {
            @Dependency(\.databaseService) var databaseService
            guard let undoManager = databaseService.undoManager() else {return}
            guard undoManager.canUndo else {throw WorkoutError.undo}
            undoManager.undo()
        }, undoManager: {
            @Dependency(\.databaseService) var databaseService
            return databaseService.undoManager()
        })
}

extension WorkoutDatabase: TestDependencyKey {
    public static var previewValue = Self {
        [.mock]
    } fetch: { _ in
        [.mock]
    } model: { _ in
        nil
    } fetchCount: { _ in
        1
    } add: { _ in
        
    } delete: { _ in
        
    } save: {
        
    } undo: {
        
    } undoManager: {
        return nil
    }
}

public enum WorkoutListFilter: Equatable {
    case none
    case today(limit: Int? = nil)
    case date(Date, limit: Int? = nil)
    case dates(date1: Date, date2: Date, limit: Int? = nil)
    case count(Int)
}

public extension WorkoutListFilter {
    static func workoutOccursBetweenDates(
        start: Date,
        end: Date,
        workout: Workout
    ) -> Bool{
        let calendar = Calendar.autoupdatingCurrent
        let start = calendar.startOfDay(for: start)
        let end = calendar.date(byAdding: .init(day: 1), to: calendar.startOfDay(for: end)) ?? end
        
        return workout.startDate > start && workout.startDate < end
    }
    
    func fetchLimit() -> Int? {
        switch self {
        case .none:
            nil
        case .today(let limit):
            limit
        case .date(_, let limit):
            limit
        case .dates(_, _, limit: let limit):
            limit
        case .count(let limit):
            limit
        }
    }
    
    func dates() -> (Date, Date) {
        let calendar = Calendar.autoupdatingCurrent
        var start = Date.distantPast
        var end = Date.distantFuture
        
        switch self {
        case .none, .count:
            break
        case .today:
            start = calendar.startOfDay(for: Date())
            end = calendar.date(byAdding: .init(day: 1), to: calendar.startOfDay(for: Date())) ?? Date()
        case .date(let startDate, _):
            start = calendar.startOfDay(for: startDate)
        case .dates(let startDate, let endDate, _):
            start = calendar.startOfDay(for: startDate)
            end = calendar.date(byAdding: .init(day: 1), to: calendar.startOfDay(for: endDate)) ?? endDate
        }
        return (start, end)
    }
}

// MARK: - Mock data

public extension Workout {
  static let mock = Workout()
}
