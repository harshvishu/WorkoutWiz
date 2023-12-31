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
    @Environment(ConcreteMessageQueue<ApplicationMessage>.self) private var globalMessageQueue
    @Environment(RouterPath.self) private var routerPath
    @Environment(WorkoutEditorViewModel.self) private var viewModel
    
    @State private var editorMessageQueue: ConcreteMessageQueue<[ExerciseTemplate]> = .init()
    @State private var showFinishAlert: Bool = false
    
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
                                
                                if viewModel.workout.abbreviatedCategory().isNotEmpty {
                                    Text("\(viewModel.workout.abbreviatedCategory())")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 8)
                                        .background(in: .capsule)
                                        .backgroundStyle(.quaternary)
                                }
                            }
                            
                            TextField("Notes", text: $viewModel.workout.notes ?? "")
                                .font(.body)
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
            }
            
            Spacer()
            
            // MARK: - Add Exercise Action
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
            
            
            if viewModel.workout.exercises.isNotEmpty {
                HStack {
                    // MARK: - Cancel Action
                    Button(role: .destructive, action: {
                        Task(priority: .userInitiated) {
                            await viewModel.discardWorkout()
                            globalMessageQueue.send(.closeWorkoutEditor)
                        }
                    }, label: {
                        Label("Cancel", systemImage: "trash.fill")
                            .padding(.horizontal)
                    })
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                 
                    Button(action: {
                        withAnimation {
                            showFinishAlert.toggle()
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
        .alert(isPresented: $showFinishAlert, content: {
            Alert(title: Text("Finish Workout?"), message: nil, primaryButton: .default(Text("Finish"), action: {
                Task(priority: .userInitiated) {
                    _ = await viewModel.finishWorkout()
                    globalMessageQueue.send(.workout)
                    viewModel.startEmptyWorkout()
                    globalMessageQueue.send(.closeWorkoutEditor)
                }
            }), secondaryButton: .cancel())
        })
        // Add Selected Exercises to the workout
        .onReceive(editorMessageQueue.signal, perform: { message in
            Task(priority: .userInitiated) {
                await viewModel.add(exerciesToWorkout: message)
            }
        })
        .navigationDestination(for: RouterDestination.self) { dest in
            switch dest {
            case .listExercise:
                ListExerciseView(messageQueue: editorMessageQueue)
            default:
                EmptyView()
            }
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

#Preview {
    @State var selectedDetent: PresentationDetent = .ExpandedSheetDetent
    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    @State var saveDataManager = SaveDataManager(saveDataUseCase: SaveDataUseCase(saveDataRepository: UserDefaultsSaveDataRepository()))
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return WorkoutEditorBottomSheetView(viewModel: viewModel, selectedDetent: $selectedDetent)
        .environment(saveDataManager)
        .environment(globalMessageQueue)
        .withPreviewModelContainer()
}

