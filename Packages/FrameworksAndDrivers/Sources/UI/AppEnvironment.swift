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

@MainActor
struct AppEnvironment: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    @State var saveDataManager = SaveDataManager(saveDataUseCase: nil)
    
    func body(content: Content) -> some View {
        content
            .environment(saveDataManager)
            .withModelContainer(preview: false)
            .addKeyboardVisibilityToEnvironment()
            .task {
                await insertTemplatesData()
            }
    }
    
    @MainActor
    private func insertTemplatesData() async {
        let templateRepository = SwiftDataTemplateRepository(listExerciseUseCase: ListExerciseUseCase(exerciseRepository: UserDefaultsExerciseTemplateRepository()))
        let container = SwiftDataModelConfigurationProvider.shared.container
        await templateRepository.insertTemplatesData(container: container)
    }
}

extension View {
    @MainActor
    func withAppEnvironment() -> some View {
        modifier(AppEnvironment())
    }
}

/// Preview Environment

@MainActor
struct PreviewAppEnvironment: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    @State var saveDataManager = SaveDataManager(saveDataUseCase: SaveDataUseCase(saveDataRepository: UserDefaultsSaveDataRepository()))
    @State var routerPath: RouterPath = .init()
    
    func body(content: Content) -> some View {
        content
            .withModelContainer(preview: true)
            .environment(saveDataManager)
            .environment(routerPath)
            .environment(SceneDelegate())
            .addKeyboardVisibilityToEnvironment()
    }
}

extension View {
    @MainActor
    func withPreviewEnvironment() -> some View {
        modifier(PreviewAppEnvironment())
    }
}
