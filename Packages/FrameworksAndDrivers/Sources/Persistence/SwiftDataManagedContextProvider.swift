//
//  SwiftDataManagedContextProvider.swift
//
//
//  Created by harsh vishwakarma on 19/12/23.
//

import SwiftUI
import SwiftData

public extension View {
    func withModelContainer() -> some View {
      modelContainer(for: [
        SD_SaveDataRecord.self,
        SD_WorkoutRecord.self,
      ], inMemory: true)
    }
    
    
#if DEBUG
    func withPreviewModelContainer() -> some View {
        modelContainer(for: [
            SD_SaveDataRecord.self,
            SD_WorkoutRecord.self,
        ], inMemory: true)
    }
#endif
    
}
