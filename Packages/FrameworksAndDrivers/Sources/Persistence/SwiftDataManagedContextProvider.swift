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
    
    @MainActor func withModelContainer(preview: Bool) -> some View {
        modifier(ModelContainerModifier(preview: preview))
    }
    
}

@MainActor
fileprivate struct ModelContainerModifier: ViewModifier {
    let configurationProvider: SwiftDataModelConfigurationProvider
    
    init(preview: Bool) {
        if preview {
            self.configurationProvider = SwiftDataModelConfigurationProvider.preview
        } else {
            self.configurationProvider = SwiftDataModelConfigurationProvider.shared
        }
    }
    
    func body(content: Content) -> some View {
        content.modelContainer(configurationProvider.container)
    }
}
