//
//  SwiftDataManagedContextProvider.swift
//
//
//  Created by harsh vishwakarma on 19/12/23.
//

import SwiftUI
import SwiftData
import Domain

public extension View {
    @MainActor
    func withModelContainer() -> some View {
        modifier(ModelContainerModifier())
    }
    
    func withPreviewModelContainer() -> some View {
        modifier(PreviewModelContainerModifier())
    }
}

fileprivate struct ModelContainerModifier: ViewModifier {
    let configurationProvider: SwiftDataModelConfigurationProvider
    
    @MainActor
    init() {
        self.configurationProvider = SwiftDataModelConfigurationProvider.shared
    }
    
    func body(content: Content) -> some View {
        content.modelContainer(configurationProvider.container)
    }
}

fileprivate struct PreviewModelContainerModifier: ViewModifier {
    let configurationProvider: SwiftDataModelConfigurationProvider
    
    init() {
        self.configurationProvider = SwiftDataModelConfigurationProvider.preview
    }
    
    func body(content: Content) -> some View {
        content.modelContainer(configurationProvider.container)
    }
}
