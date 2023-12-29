//
//  EditWorkoutSheetView.swift
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

@MainActor
public struct EditWorkoutSheetView: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: EditWorkoutSheetView.self))
    
    @Environment(\.modelContext) private var modelContext
    @Environment(ConcreteMessageQueue<ApplicationMessage>.self) private var globalMessageQueue
    
    @State private var viewModel: EditWorkoutViewModel
    @State private var messageQueue: ConcreteMessageQueue<[ExerciseTemplate]> = .init()
    @State private var routerPath: RouterPath = .init()
    
    @State private var showFinishAlert: Bool = false
    
    @Binding var selectedDetent: PresentationDetent
    
    public init(selectedDetent: Binding<PresentationDetent>) {
        self._viewModel = .init(initialValue: EditWorkoutViewModel())
        self._selectedDetent = selectedDetent
    }
    
    public init(viewModel: EditWorkoutViewModel, selectedDetent: Binding<PresentationDetent>) {
        self._viewModel = .init(initialValue: viewModel)
        self._selectedDetent = selectedDetent
    }
    
    public var body: some View {
        NavigationStack(path: $routerPath.path) {
            VStack {
                // Collapsed View
                if selectedDetent.isCollapsed {
                    Spacer()
                } else {
                    // Expanded View
                    EditWorkoutExercisesListView(viewModel: $viewModel, routerPath: $routerPath)
                    
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
                                    collapse()
                                }
                            }, label: {
                                Label("Cancel", systemImage: "trash.fill")
//                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                            })
//                            .foregroundStyle(.tertiary)
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.bordered)
                         
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
                        .background(.primary)
                        .clipShape(.capsule)
                        .transition(.slide)
                    }
                }
            }
            .padding()
            .scrollIndicators(.hidden)
            .toolbar(content: {
                
                ToolbarItem(placement: .topBarLeading) {
                    EditWorkoutSheetHeaderView(viewModel: viewModel)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        /// Actions for this button
                        /// If sheet is hidden && no exercies are added to the workout -> Start the workout with initial timer
                        /// If sheet is hidden && no exercies are added to the workout -> Show a `Start Workout` button with a faded background
                        /// If sheet is hidden && exercies are presetn in the workout -> Keep the timer running and save a value in the preferences/database preferabbly
                        ///
                        /// If sheet is visible && no exercies are aded to the workout -> Stop the workout and reset the timer
                        /// If sheet is hidden && exercies are presetn in the workout -> Do nothing when user minimizes
                        /// If sheet is hidden && exercies are presetn in the workout -> Show a button to Record/Save the workout
                        /// If sheet is hidden && exercies are presetn in the workout -> Show the `elapsed time`on the left
                        /// If sheet is hidden && exercies are presetn in the workout -> Show `Add exercise button`
                        /// If sheet is hidden && exercies are presetn in the workout -> Show `Modify exercise button`
                        
                        selectedDetent.toggle()
                        
                    }, label: {
                        if viewModel.isTimerRunning {
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
            })
            // MARK: - Alerts
            .alert(isPresented: $showFinishAlert, content: {
                Alert(title: Text("Finish Workout?"), message: nil, primaryButton: .default(Text("Finish"), action: {
                    Task(priority: .userInitiated) {
                        _ = await viewModel.finishWorkout()
                        globalMessageQueue.send(.workout)
                        viewModel.startEmptyWorkout()
                        collapse()
                    }
                }), secondaryButton: .cancel())
            })
            .onChange(of: selectedDetent) { _, newValue in
                // Sheet collapsed and ListExerciseView is visible
                // Close the ListExerciseView
                if routerPath.path.last == .listExercise && newValue == .InitialSheetDetent {
                    routerPath.path = []
                }
            }
            // Add Selected Exercises to the workout
            .onReceive(messageQueue.signal, perform: { message in
                Task(priority: .userInitiated) {
                    await viewModel.add(exerciesToWorkout: message)
                }
            })
            .task {
                viewModel.bind(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: SwiftDataWorkoutRepository(modelContext: modelContext)))
            }
            .navigationDestination(for: RouterDestination.self) { dest in
                switch dest {
                case .listExercise:
                    ListExerciseView(messageQueue: messageQueue)
                default:
                    EmptyView()
                }
            }
        }
    }
}

fileprivate extension EditWorkoutSheetView {
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
    @State var viewModel = EditWorkoutViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    @State var saveDataManager = SaveDataManager(saveDataUseCase: SaveDataUseCase(saveDataRepository: UserDefaultsSaveDataRepository()))
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return EditWorkoutSheetView(viewModel: viewModel, selectedDetent: $selectedDetent)
        .environment(saveDataManager)
        .environment(globalMessageQueue)
        .withPreviewModelContainer()
}
