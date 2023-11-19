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
    
    /// properties
    @State private var viewModel: RecordWorkoutViewModel
    @Binding private var selectedDetent: PresentationDetent
    
    public init(viewModel: RecordWorkoutViewModel = RecordWorkoutViewModel(), selectedDetent: Binding<PresentationDetent>) {
        self._viewModel = .init(initialValue: viewModel)
        self._selectedDetent = selectedDetent
    }
    
    /// view properties
    @State private var searchText = ""
    @State private var workoutName = ""
    @State private var workoutDuration = 0.0
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TextField("Workout Name", text: $workoutName)
                        .padding()
                    
                    Stepper("Workout Duration: \(workoutDuration, specifier: "%.02f") minutes", value: $workoutDuration, in: 0...120, step: 2.5)
                        .padding()
                    
                    Button("Save") {
                        let workout = Workout(duration: workoutDuration, notes: workoutName)
                        Task {
                            await viewModel.recordWorkout(workout)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .searchable(text: $searchText, placement: .automatic)
            .padding()
            .scrollIndicators(.hidden)
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Record Workout")
                        .font(.title3.bold())
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if selectedDetent == .InitialSheetDetent {
                            selectedDetent = .ExpandedSheetDetent
                        } else {
                            selectedDetent = .InitialSheetDetent
                        }
                    }, label: {
                        Image(systemName: selectedDetent == .InitialSheetDetent ? "plus" : "xmark")
                    })
                }
            })
        }
    }
}
