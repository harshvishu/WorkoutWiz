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
    // MARK: - Dependency Injection
    
    // Dependency injection for accessing the continuous clock
    @Dependency(\.continuousClock) var clock
    
    // MARK: - State Variables
    
    // Bindable store for managing the workout editor state
    @Bindable var store: StoreOf<WorkoutEditor>
    // Binding variable for the selected presentation detent
    @Binding var selectedDetent: BottomSheetPresentationState
    
    // State variable to control the animation state
    @State private var isAnimating: Bool = false
    // State variable to store the elapsed time for the workout
    @State private var elapsedTime: TimeInterval = 0
    // Task to manage the timer for elapsed time
    @State private var timerTask: Task<Void, Error>?
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            // MARK: Timer Button
            if selectedDetent.isExpanded || store.isWorkoutInProgress {
                Button(action: {
                    // TODO: Add Timer
                    // MARK: - TODO: Click on "Timer Image" Open the timer popup
                }, label: {
                    if store.isTimerRunning {
                        // Display formatted elapsed time if timer is running
                        Label(store.workout.duration.formattedElapsedTime(allowedUnits: [.hour, .minute, .second], unitsStyle: .positional), systemImage: "timer")
                    } else {
                        if selectedDetent.isExpanded {
                            // Show "Timer" label if detent is expanded
                            Label("Timer", systemImage: "timer")
                        } else {
                            // Show placeholder text if detent is collapsed
                            // TODO: Pending
                            Text("Workout in progress")
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
            
            // MARK: - TODO: Button to delete workout
            /*
            Button(role: .destructive) {
                store.send(.deleteButtonTapped, animation: .default)
            } label: {
                Label("Delete", systemImage: "trash")
                    .labelStyle(.titleAndIcon)
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .layoutPriority(1)*/
            
            // Start Workout Button
            if selectedDetent.isCollapsed {
                if store.isWorkoutInProgress {
                    // MARK: Workout Running Indicator
                    // Show running icon if workout is in progress
                    Image(systemName: "figure.run")
                        .foregroundStyle(.tertiary)
                        .symbolEffect(.pulse, isActive: store.isWorkoutInProgress)
                        .opacity(store.isWorkoutInProgress ? 1 : 0)
                } else {
                    // MARK: Start Workout button
                    // Show "Start a Workout" button if detent is collapsed and no workout is in progress
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
            // Start animation and timer when view appears
            isAnimating = true
            timerTask = Task {
                for await _ in self.clock.timer(interval: .seconds(1)) {
                    withAnimation {
                        // Increment elapsed time every second
                        elapsedTime += 1
                    }
                }
            }
        }
        .onDisappear {
            // Stop animation and timer when view disappears
            isAnimating = false
            timerTask?.cancel()
            timerTask = nil
        }
    }
}
