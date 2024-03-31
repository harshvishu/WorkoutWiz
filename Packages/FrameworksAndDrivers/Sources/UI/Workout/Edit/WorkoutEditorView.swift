//
//  WorkoutEditorView.swift
//
//
//  Created by harsh vishwakarma on 30/12/23.
//

import Domain
import SwiftUI
import DesignSystem
import Persistence
import ApplicationServices
import SwiftData
import OSLog
import ComposableArchitecture

struct WorkoutEditorView: View {
    
    @Environment(\.keyboardShowing) private var keyboardShowing
    
    @State private var alertOption: AlertOption?
    @State private var showFinishWorkoutAlert: Bool = false
    @State private var searchText = ""
    
    @Bindable var store: StoreOf<WorkoutEditor>
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            List {
                HStack(spacing: 0) {
                    
                    TextField("Workout name", text: $store.workout.name.sending(\.nameChanged))
                        .disabled(store.isWorkoutInProgress.not())
                        .font(.title3)
                        .padding(.trailing)
                    
                    Spacer()
                    
                    // TODO: Pending implementation for changing abbreviatedCategory
                    if store.workout.abbreviatedCategory != .none {
                        Button(action: {}, label: {
                            Text(store.workout.abbreviatedCategory.rawValue)
                                .font(.caption)
                        })
                        .foregroundStyle(.secondary)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .scaleEffect(0.75)
                    }
                }
                .opacity(isWorkoutNameTextFieldVisible ? 1 : 0)
                .disabled(store.isWorkoutInProgress.not())          // Disable all items inside the list
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: .defaultVerticalSpacing, leading: .defaultHorizontalSpacing, bottom: 0, trailing: .defaultHorizontalSpacing))
                
                Button(action: {
                    // TODO: Navigate to Notes Editor
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
                .buttonStyle(.plain)
                .opacity(isWorkoutNotesTextFieldVisible ? 1 : 0)
                .disabled(store.isWorkoutInProgress.not())          // Disable all items inside the list
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: .defaultHorizontalSpacing, bottom: .defaultVerticalSpacing, trailing: .defaultHorizontalSpacing))
                
                ExercisesListView(store: store.scope(state: \.exercisesList, action: \.exercisesList))
                    .disabled(store.isWorkoutInProgress.not())          // Disable all items inside the list
                    .deleteDisabled(store.isWorkoutInProgress.not())    // Disable swipe to delete
            }
            .listStyle(.inset)
            .listSectionSeparator(.hidden)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.automatic)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: .defaultVerticalSpacing) {
                    Divider()
                    
                    if store.isWorkoutInProgress {
                        
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
                                // MARK: - Cancel Action
                                Button(role: .destructive, action: {
                                    store.send(.cancelButtonTapped, animation: .default)
                                }, label: {
                                    Text("Cancel")
                                        .padding(.horizontal)
                                })
                                //                            .buttonBorderShape(.capsule)
                                //                            .buttonStyle(.bordered)
                                .foregroundStyle(Color.red)
                                //                            .overlay(Capsule().stroke(Color.red, lineWidth: 2))
                                // TODO: Check for styling
                                
                                if store.workout.exercises.isNotEmpty {
                                    Button(action: {
                                        store.send(.finishButtonTapped, animation: .default)
                                    }, label: {
                                        Text("Finish Workout")
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
                        Button(action: {
                            store.send(.startWorkoutButtonTapped, animation: .default)
                        }, label: {
                            Label(store.isWorkoutSaved ? "Resume Workout" : "Start Workout", systemImage: "play.fill")
                        })
                    }
                }
                .transition(.identity)
                .background(.ultraThinMaterial)
                .foregroundStyle(.primary)
                .opacity(keyboardShowing ? 0 : 1)
            }
            .overlay {
                if store.isWorkoutInProgress.not() && store.workout.exercises.isEmpty {
                    ContentUnavailableView("Record Workout", systemImage: "list.bullet.clipboard", description: Text("Tap on Resume Workout to add your workout details."))
                } else if store.workout.exercises.isEmpty {
                    emptyStateView
                }
            }
        }
    }
    
    private func isValid(set: Rep, forExercise exercise: Exercise) -> Bool {
        // Weight Validation
        let weightValidation = {
            let weightRequired = exercise.template?.mechanic != nil
            let isWeightAdded = set.weight > .zero
            return !weightRequired || weightRequired && isWeightAdded
        }()
        
        // Rep validation
        let repValidation = {
            let repRequired = set.countUnit == .rep
            let isRepAdded = set.count > 0
            return !repRequired || repRequired && isRepAdded
        }()
        
        // Time Required
        let timeValidation = {
            let timeRequired = set.countUnit == .time
            let isTimeAdded = set.time > .zero
            return !timeRequired || timeRequired && isTimeAdded
        }()
        
        return weightValidation && repValidation && timeValidation
    }
    
    func isCurrentWorkoutValid() async -> Bool {
        let isWorkoutInvalid = store.workout.exercises.first { exercise in
            exercise.reps.first { set in
                !isValid(set: set, forExercise: exercise)
            } != nil
        } != nil
        return !isWorkoutInvalid
    }
    
    private var isWorkoutNameTextFieldVisible: Bool {
        store.isWorkoutInProgress || store.workout.exercises.isNotEmpty || store.workout.name.isNotEmpty
    }
    private var isWorkoutNotesTextFieldVisible: Bool {
        store.isWorkoutInProgress || store.workout.exercises.isNotEmpty
    }
}

enum AlertOption: Identifiable {
    var id: String {
        switch self {
        case .invalidWorkout:
            "invalidWorkout"
        case .finishWorkout:
            "finishWorkout"
        case .openAnotherWorkout:
            "openAnotherWorkout"
        }
    }
    
    case invalidWorkout
    case finishWorkout
    case openAnotherWorkout(Workout)
    
    var titile: String {
        switch self {
        case .finishWorkout:
            "Finish Workout"
        case .invalidWorkout:
            "Finish Workout"
        case .openAnotherWorkout:
            "Save Progress"
        }
    }
    
    var messge: String {
        switch self {
        case .finishWorkout:
            "Finish Workout"
        case .invalidWorkout:
            "You have some empty sets in your workout. Do you still want to save?"
        case .openAnotherWorkout:
            "You already have a workout in progress. Do you still want to start a new one?"
        }
    }
}

fileprivate extension WorkoutEditorView {
    @ViewBuilder
    private var emptyStateView: some View {
        GeometryReader { proxy in
            VStack(alignment: .center) {
                Image(.placeholderList)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 64)
                
                Group {
                    Text("No Exercises")
                        .foregroundStyle(.primary)
                        .font(.headline)
                    
                    Text("Tap on Show All Exercises at the bottom to see list of all exercises.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            }
            .frame(width: proxy.size.width, alignment: .center)
            .frame(maxHeight: .infinity)
        }
    }
}

//#Preview {
//    WorkoutEditorView(store: StoreOf<WorkoutEditorFeature>(initialState: WorkoutEditorFeature.State(), reducer: {
//        WorkoutEditorFeature()
//    }, withDependencies: {
//        $0.workoutDatabase = .previewValue
//        
//    }))
//    .withPreviewEnvironment()
//}
