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
import Domain
import ComposableArchitecture

struct WorkoutEditorSheetHeaderView: View {
    @Dependency(\.continuousClock) var clock
    
    @Bindable var store: StoreOf<WorkoutEditor>
    @Binding var selectedDetent: PresentationDetent
    
    @State private var viewState: ViewState = .timer
    @State private var isAnimating: Bool = false
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timerTask: Task<Void, Error>?
    
    var body: some View {
        HStack(spacing: 0) {
            
            /// Show elapsed time if workout has satarted
            if store.isWorkoutInProgress {
                Button(action: {
                    // TODO: Add Timer
                }, label: {
                    HStack {
                        switch viewState {
                        case .timer:
                            Group {
//                                let estimatedElapsedTime = store.workout.duration + elapsedTime
//                                Text(estimatedElapsedTime.formattedElapsedTime())
//                                    .contentTransition(.numericText())
                                Label("Timer", systemImage: "timer")
                                    .labelStyle(.titleAndIcon)
                            }
                            .fixedSize()
                        case .calories:
                            Group {
                                let energy =  Measurement(value: store.workout.calories, unit: UnitEnergy.kilocalories)
                                Text(energy.formatted(.measurement(width: .abbreviated, usage: .workout)))
                                Image(systemName: "bolt.fill")
                            }
                            .fixedSize()
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
                
                // TODO: Marqee text
                Image(systemName: "figure.run")
                    .foregroundStyle(.tertiary)
                    .symbolEffect(.pulse, isActive: store.isWorkoutInProgress)
                    .layoutPriority(0)
                
            } else {
                /// Show record workout
                Text("Record Workout")
                    .font(.title3.bold())
                    .transition(.asymmetric(insertion: .identity, removal: .slide))
                    .layoutPriority(0)
            }
        }
        .animation(.easeInOut, value:  store.isWorkoutInProgress)
        .onAppear {
            isAnimating = true
            timerTask = Task {
                for await _ in self.clock.timer(interval: .seconds(1)) {
                    withAnimation {
                        elapsedTime += 1
                    }
                }
            }
        }
        .onDisappear {
            isAnimating = false
            timerTask?.cancel()
            timerTask = nil
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

//#Preview {
//    return WorkoutEditorSheetHeaderView()
//        .withPreviewEnvironment()
//}
