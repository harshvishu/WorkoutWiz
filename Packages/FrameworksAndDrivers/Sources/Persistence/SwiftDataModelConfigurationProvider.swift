//
//  SwiftDataModelConfigurationProvider.swift
//  
//
//  Created by harsh vishwakarma on 15/02/24.
//

import Foundation
import SwiftData
import Domain

//@MainActor
public class SwiftDataModelConfigurationProvider {
    public static let shared = SwiftDataModelConfigurationProvider()
    
    /// A provider for use with canvas previews.
    public static let preview: SwiftDataModelConfigurationProvider = {
        let provider = SwiftDataModelConfigurationProvider(isStoredInMemoryOnly: true)
        return provider
    }()
    
    private var isStoredInMemoryOnly: Bool
    private var autosaveEnabled: Bool
    
    private init(isStoredInMemoryOnly: Bool = false, autosaveEnabled: Bool = true) {
        self.isStoredInMemoryOnly = isStoredInMemoryOnly
        self.autosaveEnabled = autosaveEnabled
    }
    
    @MainActor
    public lazy var container: ModelContainer = {
        let schema = Schema(
            [
                SD_SaveDataRecord.self,
                Rep.self,
                Exercise.self,
                Workout.self,
                ExerciseBluePrint.self
            ]
        )
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        container.mainContext.autosaveEnabled = autosaveEnabled
        return container
    }()
}
