//
//  WorkoutEditorBottomSheetView.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Domain
import SwiftUI
import DesignSystem
import Persistence
import ApplicationServices
import SwiftData
import OSLog
import ComposableArchitecture

struct WorkoutEditorBottomSheetView: View {
    
    // MARK: - Environment
    // Keyboard state environment variable
    @Environment(\.keyboardShowing) private var keyboardShowing
    
    // MARK: - State Variables
    
    // Bindable store for managing the workout editor state
    @Bindable var store: StoreOf<WorkoutEditor>
    // Binding variable for the selected presentation detent
    @Binding var selectedDetent: BottomSheetPresentationState
    
    // MARK: - Initializer
    
    // Custom initializer to set the store and selectedDetent
    init(store: StoreOf<WorkoutEditor>, selectedDetent: Binding<BottomSheetPresentationState>) {
        self.store = store
        self._selectedDetent = selectedDetent
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            // Main content: WorkoutEditorView
            WorkoutEditorView(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(selectedDetent.isCollapsed ? 0 : 1)
                .scrollIndicators(.hidden)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    // Bottom safe area content
                    
                    VStack(spacing: .defaultVerticalSpacing) {
                        Divider()
                        
                        if store.isWorkoutInProgress {
                            // Buttons for in-progress workout
                            
                            // Button to show all exercises
                            Button(action: {
                                store.send(.showExerciseListButtonTapped, animation: .default)
                            }, label: {
                                Text("Show All Exercises")
                                    .frame(maxWidth: .infinity)
                            })
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.bordered)
                            .foregroundStyle(.primary)
                            .overlay(Capsule().stroke(Color.secondary, lineWidth: 2))
                            .padding(.horizontal, .defaultHorizontalSpacing)
                            
                            HStack {
                                // Cancel button
                                Button(role: .destructive, action: {
                                    store.send(.cancelButtonTapped, animation: .default)
                                }, label: {
                                    Text("Cancel")
                                        .padding(.horizontal)
                                })
                                .foregroundStyle(Color.red)
                                
                                // Finish button if exercises are added
                                if store.workout.exercises.isNotEmpty {
                                    Button(action: {
                                        store.send(.finishButtonTapped, animation: .default)
                                    }, label: {
                                        // Label for finish button
                                        Text(store.isNewWorkout ? "Finish Workout" : "Done")
                                            .frame(maxWidth: .infinity)
                                    })
                                    .buttonBorderShape(.capsule)
                                    .buttonStyle(.borderedProminent)
                                    .tint(.primary)
                                    .foregroundStyle(.background)
                                }
                            }
                            .padding(.horizontal, .defaultHorizontalSpacing)
                        } else {
                            
                            // Button to start or resume workout
                            Button(action: {
                                store.send(.startWorkoutButtonTapped, animation: .default)
                            }, label: {
                                Label(store.isWorkoutSaved ? "Resume Workout" : "Start Workout", systemImage: "play.fill")
                            })
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .transition(.identity)
                    .background(.ultraThinMaterial)
                    .foregroundStyle(.primary)
                    .opacity(selectedDetent.isCollapsed || keyboardShowing ? 0 : 1) // Hide when keyboard is showing
                }
                .toolbar {
                    // Top bar leading items
                    ToolbarItemGroup(placement: .topBarLeading) {
                        // WorkoutEditorSheetHeaderView
                        WorkoutEditorSheetHeaderView(store: store, selectedDetent: $selectedDetent)
                    }
                    
                    // Top bar trailing items
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        // Expand/Collapse button
                        Button(action: {
                            // Hides the keyboard
                            hideKeyboard()
                            // Sends a delegate action to expand or collapse the view
                            store.send(.delegate(selectedDetent.isCollapsed ? .expand : .collapse), animation: .default)
                        }, label: {
                            // Adjusts icon based on workout progress and selected detent state
                            if store.isWorkoutInProgress {
                                Image(systemName: "chevron.up")
                                    .foregroundStyle(.secondary)
                                    .rotationEffect(Angle(degrees: selectedDetent.isCollapsed ? 0 : 180))
                            } else {
                                Image(systemName: "plus")
                                    .foregroundStyle(.secondary)
                                    .rotationEffect(Angle(degrees: selectedDetent.isCollapsed ? 0 : 360 + 45))
                            }
                        })
                        .foregroundStyle(.primary)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                    }
                }
        } destination: { store in
            // Destination view based on the store's current state
            switch store.case {
            case let .exerciseLists(store):
                // ExerciseTemplatesListView when the store's case is .exerciseLists
                ExerciseTemplatesListView(store: store)
            case let .exerciseDetails(store):
                // ExerciseDetailView when the store's case is .exerciseDetails
                ExerciseTemplateDetailView(store: store)
            }
        }
    }
}
