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

@MainActor
public struct WorkoutEditorView: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: WorkoutEditorView.self))
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(RouterPath.self) private var routerPath
    @Environment(WorkoutEditorViewModel.self) private var viewModel
    @Environment(\.keyboardShowing) private var keyboardShowing
    
    @State private var editorMessageQueue: ConcreteMessageQueue<[ExerciseTemplate]> = .init()
    @State private var alertOption: AlertOption?
    @State private var showFinishWorkoutAlert: Bool = false
    
    public var body: some View {
        @Bindable var viewModel = viewModel
        Group {
            // Expanded View
            VStack {
                List {
                    Section {
                        // TODO: replace with an enum to handle the states
                        
                        VStack(alignment: .leading) {
                            HStack {
                                TextField("Workout name", text: $viewModel.workout.name)
                                    .font(.title3)
                                
                                Spacer()
                                
                                if let abbreviatedCategory = viewModel.workout.abbreviatedCategory() {
                                    Button(action: {}, label: {
                                        Text(abbreviatedCategory.rawValue)
                                            .font(.caption)
                                    })
                                    .foregroundStyle(.secondary)
                                    .buttonStyle(.bordered)
                                    .buttonBorderShape(.capsule)
                                    .scaleEffect(0.75)
                                }
                            }
                            
                            Text(viewModel.workout.notes ?? "Notes")
                                .truncationMode(.tail)
                                .foregroundStyle(.tertiary)
                                .font(.body)
                                .onTapGesture {
                                    logger.info("Add notes for workout: TODO: Pending implementation")
                                }
                        }
                        
                        WorkoutEditorExerciseListView()
                        
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.listRowInset)
                }
                // List Styling
                .listSectionSeparator(.hidden)
                .listRowSpacing(.listRowVerticalSpacing)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.automatic)
            }
            
            Spacer()
            
            // MARK: - Add Exercise Action
            if !keyboardShowing {
                Button(action: {
                    withCustomSpring {
                        routerPath.navigate(to: .listExercise)
                    }
                }, label: {
                    Text("Show All Exercises")
                        .frame(maxWidth: .infinity)
                })
                .foregroundStyle(.primary)
                .tint(.clear)
                .buttonStyle(.bordered)
                .overlay(
                    Capsule()
                        .stroke(Color.secondary, lineWidth: 2) // Set the stroke color and width
                )
                .transition(.opacity)
//                .opacity(keyboardShowing ? 0 : 1)
            }
            
            if viewModel.workout.exercises.isNotEmpty && keyboardShowing == false {
                HStack {
                    // MARK: - Cancel Action
                    Button(role: .destructive, action: {
                        Task(priority: .userInitiated) {
                            await viewModel.discardWorkout()
                            appState.send(.closeWorkoutEditor)
                        }
                    }, label: {
                        Label("Cancel", systemImage: "trash.fill")
                            .padding(.horizontal)
                    })
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                    
                    Button(action: {
                        Task {
                            let isCurrentWorkoutValid = await viewModel.isCurrentWorkoutValid()
                            withCustomSpring {
                                if isCurrentWorkoutValid {
                                    logger.debug("showFinishAlert")
                                    alertOption = AlertOption.finishWorkout
                                } else {
                                    logger.debug("showWorkoutInvalidAlert")
                                    alertOption = AlertOption.invalidWorkout
                                }
                                showFinishWorkoutAlert = true
                            }
                        }
                        
                    }, label: {
                        Text("Finish Workout")
                            .frame(maxWidth: .infinity)
                    })
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                }
                .padding(4)
                .clipShape(.capsule)
            }
        }
        // MARK: - Alerts
        .alert("Finish Workout", isPresented: $showFinishWorkoutAlert, presenting: alertOption) { options in
            Button(action: {
                _ = finishWorkoutTask()
            }) {
                Text("Yes")
            }
            Button(role: .cancel) {
                // Handle the deletion.
            } label: {
                Text("Cancel")
            }
        } message: { options in
            switch options {
            case .invalidWorkout:
                Text("You have some empty sets in your workout. Do you still want to save?")
            case .finishWorkout:
                EmptyView()
            }
        }
        // Add Selected Exercises to the workout
        .onReceive(editorMessageQueue.signal, perform: { message in
            Task(priority: .userInitiated) {
                await viewModel.add(exerciesToWorkout: message)
            }
        })
        .navigationDestination(for: RouterDestination.self) { dest in
            switch dest {
            case .listExercise:
                ListExerciseTemplatesView(messageQueue: editorMessageQueue, canSelect: true)
                    .environment(routerPath)
            default:
                EmptyView()
            }
        }
    }
    
    private func finishWorkoutTask() -> Task<(), Never> {
        Task(priority: .userInitiated) {
            _ = await viewModel.finishWorkout()
            appState.send(.workoutFinished)
            viewModel.initWithEmptyWorkout()
            appState.send(.closeWorkoutEditor)
        }
    }
}

fileprivate extension WorkoutEditorBottomSheetView {
    func collapse()  {
        withEaseOut {
            selectedDetent = .InitialSheetDetent
        }
    }
    
    func exapand() {
        withEaseOut {
            selectedDetent = .ExpandedSheetDetent
        }
    }
}

enum AlertOption: Identifiable {
    var id:  Self { self }
    
    case invalidWorkout
    case finishWorkout
}

#Preview {
    @State var selectedDetent: PresentationDetent = .ExpandedSheetDetent
    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    
    return WorkoutEditorBottomSheetView(viewModel: viewModel, selectedDetent: $selectedDetent)
        .withPreviewEnvironment()
}

