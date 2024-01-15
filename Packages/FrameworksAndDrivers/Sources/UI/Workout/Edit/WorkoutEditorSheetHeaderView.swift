//
//  WorkoutEditorSheetHeaderView.swift
//
//
//  Created by harsh vishwakarma on 29/12/23.
//

import SwiftUI
import DesignSystem
import Persistence
import ApplicationServices

struct WorkoutEditorSheetHeaderView: View {
    @Environment(WorkoutEditorViewModel.self) private var viewModel
    
    @State private var viewState: ViewState = .timer
    @State private var isAnimating: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            
            /// Show elapsed time if workout has satarted
            if viewModel.isTimerRunning {
                Button(action: {
                    /// Show a popup timer with options to reset the time
                    /// A Context Menu
                    withAnimation(.linear) {
                        viewState.toggle()
                    }
                }, label: {
                    HStack {
                        switch viewState {
                        case .timer:
                            Group {
                                Text(viewModel.workout.startDate, style: .timer)
                                    .contentTransition(.numericText(value: 1))
                                Image(systemName: "timer")
                            }
                            .fixedSize()
                            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
                        case .calories:
                            Group {
                                let energy =  Measurement(value: viewModel.workout.estimatedCaloriesBurned(), unit: UnitEnergy.kilocalories)
                                Text(energy.formatted(.measurement(width: .abbreviated, usage: .workout)))
                                Image(systemName: "bolt.fill")
                            }
                            .fixedSize()
                            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
                        }
                    }
                    .layoutPriority(1)
                })
                .font(.headline.monospaced())
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .foregroundStyle(.white)
                .scaleEffect(0.75)
                .layoutPriority(1)
                .previewBorder()
                
                // TODO: Optimize
                Label("In Progress...", systemImage: "figure.run")
                    .foregroundStyle(.tertiary)
                    .symbolEffect(.pulse, isActive: isAnimating)
                    .layoutPriority(0)
                    .previewBorder()
                    .clipped()
                
                
            } else {
                /// Show record workout
                Text("Record Workout")
                    .font(.title3.bold())
                    .transition(.asymmetric(insertion: .identity, removal: .slide))
                    .layoutPriority(0)
                    .previewBorder()
            }
        }
        .animation(.easeInOut, value:  viewModel.isTimerRunning)
        .onAppear {
            isAnimating = true
        }
    }
}

fileprivate enum ViewState {
    case calories
    case timer
    
    mutating func toggle() {
        switch self {
        case .calories:
            self = .timer
        case .timer:
            self = .calories
        }
    }
}

#Preview {
    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
  
    return WorkoutEditorSheetHeaderView()
        .withPreviewEnvironment()
        .environment(viewModel)
        .onTapGesture {
            Task {
                await viewModel.startTimer()
            }
        }
}
