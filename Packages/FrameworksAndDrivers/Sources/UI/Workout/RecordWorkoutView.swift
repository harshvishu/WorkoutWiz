//
//  RecordWorkoutView.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Domain
import SwiftUI
import DesignSystem

@MainActor
public struct RecordWorkoutView: View {
    @State private var searchText = ""
    
    @State private var workoutName = ""
    @State private var workoutDuration = 0.0
    
    @State private var viewModel: RecordWorkoutViewModel
    @State private var exerciseViewModel: ListExerciseViewModel
    
    public init(viewModel: RecordWorkoutViewModel, exerciseViewModel: ListExerciseViewModel) {
        self._viewModel = .init(initialValue: viewModel)
        self._exerciseViewModel = .init(initialValue: exerciseViewModel)
    }
    
    public var body: some View {
        ZStack {
            VStack {
                TextField("Workout Name", text: $workoutName)
                    .padding()
                
                Stepper("Workout Duration: \(workoutDuration, specifier: "%.02f") minutes", value: $workoutDuration, in: 0...120, step: 2.5)
                    .padding()
                
                Button("Record Workout") {
                    let workout = Workout(duration: workoutDuration, notes: workoutName)
                    Task {
                        await viewModel.recordWorkout(workout)
                    }
                }
                .padding()
                
                Spacer()
            }
            
            if !searchText.isEmpty {
                ListExerciseView(viewModel: exerciseViewModel)
            }
        }
       
        .searchable(text: $searchText, placement: .automatic)
        .padding()
        .navigationBarTitle("Record Workout")
    }
}
