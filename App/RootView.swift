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
        NavigationStack {
            ListExerciseView(viewModel: ListExerciseViewModel(listExerciseUseCase: ListExerciseUseCase(exerciseRepository: SwiftDataExerciseRepository())))
            
            RecordWorkoutView(viewModel: RecordWorkoutViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: FirebaseWorkoutRepository())))
        }
    }
}
