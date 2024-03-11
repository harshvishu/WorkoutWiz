//
//  Database.swift
//  
//
//  Created by harsh vishwakarma on 07/03/24.
//

import ComposableArchitecture
import Domain
import SwiftData
import Foundation

// MARK: Golbal Swift Data Dependency
extension DependencyValues {
    var databaseService: Database {
        get {self[Database.self]}
        set{self[Database.self] = newValue}
    }
}

struct Database {
    var context: () throws -> ModelContext
}

extension Database: DependencyKey {
    public static let liveValue = Self(
        context: { appContext }
    )
}

let appContext: ModelContext = {
    let container = SwiftDataModelConfigurationProvider.shared.container
    let context = ModelContext(container)
    context.autosaveEnabled = true
    return context
}()
