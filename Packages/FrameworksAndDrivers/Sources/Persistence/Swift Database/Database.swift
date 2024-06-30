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
    var context: () -> ModelContext
    var undoManager: () -> UndoManager?
}

extension Database: DependencyKey {
    @MainActor
    public static let liveValue = Self(
        context: { appContext },
        undoManager: {appContext.undoManager}
    )
}

@MainActor
let appContext: ModelContext = {
    let container = SwiftDataModelConfigurationProvider.shared.container
    let context = ModelContext(container)
    context.undoManager = UndoManager()
    context.autosaveEnabled = SwiftDataModelConfigurationProvider.shared.autosaveEnabled
    return context
}()

@MainActor
let preivewAppContext: ModelContext = {
    let container = SwiftDataModelConfigurationProvider.preview.container
    let context = ModelContext(container)
    return context
}()
