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
    
    var body: some View {
        HStack(spacing: 0) {
            
            /// Show elapsed time if workout has satarted
            if viewModel.isTimerRunning {
                Button(action: {
                    /// Show a popup timer with options to reset the time
                    /// A Context Menu
                    withCustomSpring {
                        viewState.toggle()
                    }
                }, label: {
                    HStack {
                        switch viewState {
                        case .timer:
                            Group {
                                Text(viewModel.startTime ?? .now, style: .timer)
                                Image(systemName: "timer")
                            }
                        case .calories:
                            Group {
                                // TODO: Fix the values
                                let energy =  Measurement(value: viewModel.totalCaloriesBurned, unit: UnitEnergy.kilocalories)
                                Text(energy, format: .measurement(width: .narrow, numberFormatStyle: .number.rounded()))
                                Image(systemName: "bolt.fill")
                            }
                        }
                    }
                })
                .font(.headline.monospaced())
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .foregroundStyle(.primary)
                .transition(.asymmetric(insertion: .slide, removal: .identity))
                .scaleEffect(0.75)
                .previewBorder()
                
                Text("In Progress")
                    .font(.headline)
                    .foregroundStyle(.tertiary)
                    .transition(.asymmetric(insertion: .identity, removal: .slide))
                    .previewBorder()
                
                
            } else {
                /// Show record workout
                Text("Record Workout")
                    .font(.title3.bold())
                    .transition(.asymmetric(insertion: .identity, removal: .slide))
                    .previewBorder()
            }
        }
        .animation(.easeInOut, value:  viewModel.isTimerRunning)
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
    @State var saveDataManager = SaveDataManager(saveDataUseCase: SaveDataUseCase(saveDataRepository: UserDefaultsSaveDataRepository()))
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return WorkoutEditorSheetHeaderView()
        .environment(viewModel)
        .environment(saveDataManager)
        .environment(globalMessageQueue)
        .withPreviewModelContainer()
        .onTapGesture {
            Task {
                await viewModel.startTimer()
            }
        }
}
