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
    
    @State private var isAnimating: Bool = false
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timerTask: Task<Void, Error>?
    
    var body: some View {
        HStack {
            // TODO: Fix weird animation bug
            if selectedDetent.isExpanded || store.isWorkoutInProgress {
                Button(action: {
                    // TODO: Add Timer
                    // MARK: - TODO: Click on "Timer Image" Open the timer popup
                }, label: {
                    if store.isTimerRunning {
                        Label(store.workout.duration.formattedElapsedTime(allowedUnits: [.hour, .minute, .second], unitsStyle: .positional), systemImage: "timer")
                    } else {
                        if selectedDetent.isExpanded {
                            Label("Timer", systemImage: "timer")
                        } else {
                            // TODO: Pending
                            Text("Workout in progres")
                        }
                    }
                })
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                .foregroundStyle(.background)
                .labelStyle(.titleAndIcon)
                .layoutPriority(1)
            }
            
            if selectedDetent.isCollapsed {
                if store.isWorkoutInProgress {
                    Image(systemName: "figure.run")
                        .foregroundStyle(.tertiary)
                        .symbolEffect(.pulse, isActive: store.isWorkoutInProgress)
                        .opacity(store.isWorkoutInProgress ? 1 : 0)
                } else {
                    Button {
                        store.send(.delegate(.expand), animation: .default)
                    } label: {
                        Text("Start a Workout")
                    }
                    .tint(.primary)
                    .font(.headline)
                }
            }
            
        }
        .transition(.identity)
        .font(.caption)
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

//#Preview {
//    return WorkoutEditorSheetHeaderView()
//        .withPreviewEnvironment()
//}
