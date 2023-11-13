//
//  ContentView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 06/11/23.
//

import SwiftUI
import SwiftData
import DesignSystem
import ApplicationServices
import Persistence
import UI

struct RootView: View {
    
    var body: some View {
        NavigationSplitView {
            ListExerciseView(viewModel: ListExerciseViewModel(listExerciseUseCase: ListExerciseUseCase(exerciseRepository: SwiftDataExerciseRepository())))
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
            }
        } detail: {
            Text("Select an item")
        }
    }
}
