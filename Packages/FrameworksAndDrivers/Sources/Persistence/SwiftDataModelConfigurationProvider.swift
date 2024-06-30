//
//  SwiftDataModelConfigurationProvider.swift
//  
//
//  Created by harsh vishwakarma on 15/02/24.
//

import Foundation
import SwiftData
import Domain

public class SwiftDataModelConfigurationProvider {
    public static let shared = SwiftDataModelConfigurationProvider(isStoredInMemoryOnly: false, autosaveEnabled: true)
    
    /// A provider for use with canvas previews.
    public static let preview: SwiftDataModelConfigurationProvider = {
        let provider = SwiftDataModelConfigurationProvider(isStoredInMemoryOnly: true, autosaveEnabled: false)
        return provider
    }()
    
    private(set) public var isStoredInMemoryOnly: Bool
    private(set) public var autosaveEnabled: Bool
    
    private init(isStoredInMemoryOnly: Bool, autosaveEnabled: Bool) {
        self.isStoredInMemoryOnly = isStoredInMemoryOnly
        self.autosaveEnabled = autosaveEnabled
    }
    
    @MainActor
    public lazy var container: ModelContainer = {
        let schema = Schema(
            [
                Rep.self,
                Exercise.self,
                Workout.self,
                ExerciseTemplate.self
            ]
        )
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        container.mainContext.autosaveEnabled = autosaveEnabled
        return container
    }()
}
