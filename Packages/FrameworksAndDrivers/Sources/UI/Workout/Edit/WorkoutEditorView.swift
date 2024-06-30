//
//  WorkoutEditorView.swift
//
//
//  Created by harsh vishwakarma on 30/12/23.
//

import Domain
import SwiftUI
import DesignSystem
import OSLog
import ComposableArchitecture
import Persistence

struct WorkoutEditorView: View {
    
    // MARK: - Environment Variables
    
    // Keyboard state environment variable
    @Environment(\.keyboardShowing) private var keyboardShowing
    
    // MARK: - State Variables
    
    // State variable to store the search text for filtering exercises
    @State private var searchText = ""
    
    // MARK: - Bindable Store
    
    // Bindable store for managing the workout editor state
    @Bindable var store: StoreOf<WorkoutEditor>
    
    @Dependency(\.workoutDatabase.undoManager) var undoManager
    
    // MARK: - Body
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main content stack
            
            List {
                // List of workout editor components
                Group {
                    // MARK: Workout name text field
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            TextField("Workout name", text: $store.workout.name.sending(\.nameChanged).animation(.default))
                                .disabled(store.isWorkoutInProgress.not()) // Disable if workout is not in progress
                                .font(.title3)
                                .padding(.trailing)
                            
                            Spacer()
                            
                            if (store.workout.abbreviatedCategory != .none) {
                                // MARK: Button for changing workout category
                                Button(action: {}, label: {
                                    Label(store.workout.abbreviatedCategory.rawValue, systemImage: "tag.fill")
                                        .font(.caption.weight(.medium))
                                        .labelStyle(.titleAndIcon)
                                })
                                .foregroundStyle(.secondary)
                                .buttonBorderShape(.capsule)
                                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                .background {
                                    Capsule(style: .continuous)
                                        .fill(.quinary.opacity(0.3))
                                        .stroke(.secondary, lineWidth: 0.5)
                                }
                                
                            }
                        }
                        .opacity(isWorkoutNameTextFieldVisible ? 1 : 0) // Show only if visible
                        .disabled(store.isWorkoutInProgress.not()) // Disable if workout is not in progress
                        
                        // MARK: Button for adding notes to the workout
                        Button(action: {
                            // Navigate to Notes Editor
                            Logger.ui.info("Add notes for workout: TODO: Pending implementation")
                        }, label: {
                            HStack {
                                Text("Notes")
                                Image(systemName: "pencil.and.list.clipboard")
                                    .font(.caption)
                            }
                            .foregroundStyle(.tertiary)
                            .font(.body)
                        })
                        .opacity(isWorkoutNotesTextFieldVisible ? 1 : 0) // Show only if visible
                        .disabled(store.isWorkoutInProgress.not()) // Disable if workout is not in progress
                    }
                    .listRowInsets(.init(top: 0, leading: .defaultHorizontalSpacing, bottom: .defaultVerticalSpacing, trailing: .defaultHorizontalSpacing))
                    
                    // List of exercises
                    ExercisesListView(store: store.scope(state: \.exercisesList, action: \.exercisesList), isEditable: store.isWorkoutInProgress)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: .defaultHorizontalSpacing, bottom: 0, trailing: .defaultHorizontalSpacing))
                .disabled(store.isWorkoutInProgress.not()) // Disable if workout is not in progress
                .buttonStyle(.plain)
                .previewBorder()
            }
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(.inset)
            .listSectionSeparator(.hidden)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.automatic)
            .overlay {
                // Overlay views for empty state messages
                
                if store.isWorkoutInProgress.not() && store.workout.exercises.isEmpty {
                    // Show empty state for recording workout
                    EmptyStateView(title: "Record Workout", subtitle: "Tap on Resume Workout to add your workout details.", resource: .placeholderForms)
                } else if store.workout.exercises.isEmpty {
                    // Show empty state for no exercises
                    EmptyStateView(title: "No Exercises", subtitle: "Tap on Show All Exercises at the bottom to see list of all exercises.", resource: .placeholderList)
                }
            }
            .safeAreaPadding(.bottom, .defaultVerticalSpacing)
            // FIXME: Undo manager needs a separate Undo Stack. Will add this feature later
            /*
            .overlay(alignment: .bottomTrailing) {
                // Add exercise button overlay
                if store.isWorkoutInProgress && undoManager()?.canUndo == true {
                    Button(action: {
                        store.send(.undoButtonTapped, animation: .default)
                    }, label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    })
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .shadow(radius: 2)
                    .padding(.horizontal, .defaultHorizontalSpacing)
                    .padding(.vertical, .defaultVerticalSpacing)
                    .transition(.scale)
                } else {
                    EmptyView()
                }
            }*/
            // Alerts for workout editor view
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        }
    }
    
    // MARK: - Computed Properties
    
    // Computed property to determine the visibility of the workout name text field
    private var isWorkoutNameTextFieldVisible: Bool {
        store.isWorkoutInProgress || store.workout.exercises.isNotEmpty || store.workout.name.isNotEmpty
    }
    
    // Computed property to determine the visibility of the workout notes text field
    private var isWorkoutNotesTextFieldVisible: Bool {
        store.isWorkoutInProgress || store.workout.exercises.isNotEmpty
    }
}

#Preview {
    let container = SwiftDataModelConfigurationProvider.shared.container
    
    return NavigationStack {
        WorkoutEditorView(store: StoreOf<WorkoutEditor>(initialState: WorkoutEditor.State(), reducer: {
            WorkoutEditor()
        }))
    }
    .modelContainer(container)
}
