//
//  PreviewAppEnvironment.swift
//  
//
//  Created by harsh vishwakarma on 15/01/24.
//

import SwiftUI
import Domain
import ApplicationServices
import Persistence
import DesignSystem

@MainActor
struct PreviewAppEnvironment: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    @State var saveDataManager = SaveDataManager(saveDataUseCase: SaveDataUseCase(saveDataRepository: UserDefaultsSaveDataRepository()))
    @State var appState = AppState()
    @State var routerPath: RouterPath = .init()
    
    func body(content: Content) -> some View {
        content
            .withPreviewModelContainer()
            .environment(appState)
            .environment(saveDataManager)
            .environment(routerPath)
            .environment(SceneDelegate())
            .addKeyboardVisibilityToEnvironment()
            .task {
                initializeSwiftDataManager()
            }
    }
    
    fileprivate func initializeSwiftDataManager() {
        guard saveDataManager.saveDataUseCase == nil else {return}
        saveDataManager.saveDataUseCase = SaveDataUseCase(saveDataRepository: SwiftDataSaveDataRepository(modelContext: modelContext))
    }
}

extension View {
    @MainActor func withPreviewEnvironment() -> some View {
        modifier(PreviewAppEnvironment())
    }
}

