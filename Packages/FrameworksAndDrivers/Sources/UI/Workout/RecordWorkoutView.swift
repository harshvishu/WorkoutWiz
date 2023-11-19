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
    
//    @State private var routerPath = RouterPath()
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    
                    if let startTime = viewModel.startTime {
                        Text(startTime, style: .relative)
                    }
                    
                    NavigationLink(destination: ListExerciseView()) {
                        Text("Add Exercise")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Stepper("Workout Duration: \(workoutDuration, specifier: "%.02f") minutes", value: $workoutDuration, in: 0...120, step: 2.5)
                        .padding()
                    
                    Button("Save") {
                        let workout = Workout(duration: workoutDuration, notes: workoutName)
                        Task {
                            await viewModel.recordWorkout(workout)
                        }
                    }
                    .padding()
                    
                    HStack {
                        Button {
                            Task {
                                await viewModel.startTimer()
                            }
                        } label: {
                            Text("Start Workout")
                        }
                        
                        Button {
                            Task {
                                await viewModel.endTimer()
                            }
                        } label: {
                            Text("End Workout")
                        }

                        Button {
                            Task {
                                await viewModel.resetTimer()
                            }
                        } label: {
                            Text("Reset Workout")
                        }
                    }
                    
                    Spacer()
                }
            }
            .searchable(text: $searchText, placement: .automatic, prompt: "Search exercises")
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
                        
                        if !viewModel.isTimerRunning {
                            Task {
                                await viewModel.startTimer()
                            }
                        }
                    }, label: {
                        Image(systemName: selectedDetent == .InitialSheetDetent ? "plus" : "xmark")
                    })
                }
            })
//            .withAppRouter()
//            .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
        }
    }
}
