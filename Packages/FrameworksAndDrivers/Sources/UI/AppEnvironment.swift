//
//  AppEnvironment.swift
//  
//
//  Created by harsh vishwakarma on 15/01/24.
//

import SwiftUI
import Domain
import ApplicationServices
import Persistence
import DesignSystem
import SwiftData
import TipKit

@MainActor
struct AppEnvironment: ViewModifier {
        
    func body(content: Content) -> some View {
        content
            .withModelContainer()
            .addKeyboardVisibilityToEnvironment()
            .task {
                await insertTemplatesData()
            }
            .task {
                try? Tips.configure([.datastoreLocation(.applicationDefault)])
            }
    }
    
    @MainActor
    private func insertTemplatesData() async {
        let templateRepository = SwiftDataTemplateRepository(listExerciseUseCase: ListExerciseUseCase(exerciseRepository: UserDefaultsExerciseTemplateRepository()))
        let container = SwiftDataModelConfigurationProvider.shared.container
        await templateRepository.insertTemplatesData(container: container)
    }
    
}

/// Preview Environment
struct PreviewAppEnvironment: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .withPreviewModelContainer()
            .environment(SceneDelegate())
            .addKeyboardVisibilityToEnvironment()
            .task {
//                try? Tips.resetDatastore()
                try? Tips.configure([.datastoreLocation(.applicationDefault)])
            }
    }
}

extension View {
    @MainActor
    func withAppEnvironment() -> some View {
        modifier(AppEnvironment())
    }
    
    func withPreviewEnvironment() -> some View {
        modifier(PreviewAppEnvironment())
    }
}
