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

//@MainActor
public struct WorkoutEditorView: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: WorkoutEditorView.self))
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.keyboardShowing) private var keyboardShowing
    @Environment(AppState.self) private var appState
    @Environment(RouterPath.self) private var routerPath
    @Environment(WorkoutEditorViewModel.self) private var viewModel

    @State private var exerciseSelector: ConcreteMessageQueue<[ExerciseBluePrint]> = .init()
    @State private var alertOption: AlertOption?
    @State private var showFinishWorkoutAlert: Bool = false
    
    @State var isWorkoutSaved: Bool
    @State var isWorkoutInProgress: Bool
    @State var workout: Workout
    @State private var searchText = ""
    
    public init() {
        self._isWorkoutSaved = .init(initialValue: false)
        self._isWorkoutInProgress = .init(initialValue: false)
        self._workout = .init(initialValue:  Workout())
    }
    
    public var body: some View {
        ZStack {
            VStack {
                // Expanded View
                
                ScrollView(.vertical, showsIndicators: false) {
                    //                    List {
                    //                        Section {
                    // TODO: replace with an enum to handle the states
                    
                    LazyVStack(alignment: .leading) {
                        HStack {
                            TextField("Workout name", text: $workout.name)
                                .font(.title3)
                            
                            Spacer()
                            
                            if workout.abbreviatedCategory != .none {
                                Button(action: {}, label: {
                                    Text(workout.abbreviatedCategory.rawValue)
                                        .font(.caption)
                                })
                                .foregroundStyle(.secondary)
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                .scaleEffect(0.75)
                            }
                        }
                        
                        Text("Notes")
                            .truncationMode(.tail)
                            .foregroundStyle(.tertiary)
                            .font(.body)
                            .onTapGesture {
                                logger.info("Add notes for workout: TODO: Pending implementation")
                            }
                        
                        if workout.exercises.isNotEmpty {
                            WorkoutEditorExerciseListView(exercises: workout.exercises)
                        } else {
                            emptyStateView
                        }
                        
                    }
                    
                    //                        }
                    //                        .listRowSeparator(.hidden)
                    //                        .listRowInsets(.listRowInset)
                    //                    }
                    // List Styling
                    //                    .listSectionSeparator(.hidden)
                    //                    .listRowSpacing(.listRowVerticalSpacing)
                    //                    .listStyle(.plain)
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
                }
                
                if (workout.exercises.isNotEmpty) && keyboardShowing == false {
                    HStack {
                        // MARK: - Cancel Action
                        Button(role: .destructive, action: {
                            // TODO: Handle the deletion.
//                            if isWorkoutSaved {
//                                modelContext.delete(workout)
//                            }
                            appState.send(.closeWorkoutEditor)
                            workout = Workout()
                            isWorkoutSaved = false
                            isWorkoutInProgress = false
                            viewModel.isWorkoutActive = false
                        }, label: {
                            Label("Cancel", systemImage: "trash.fill")
                                .padding(.horizontal)
                        })
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)
                        .foregroundStyle(.primary)
                        
                        Button(action: {
                            Task {
                                let isCurrentWorkoutValid = await isCurrentWorkoutValid()
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
        }
        // MARK: - Alerts
        .alert(alertOption?.titile ?? "Alert", isPresented: $showFinishWorkoutAlert, presenting: alertOption) { options in
            Button(action: {
                if case .openAnotherWorkout(let workoutToOpen) = options {
                    workout = workoutToOpen
                    isWorkoutSaved = true
                    isWorkoutInProgress = false
                    appState.send(.openEditWorkoutSheet)
                    viewModel.resume(workout: workout)
                } else {
                    finish()
                }
            }) {
                Text("Yes")
            }
            Button(role: .cancel) {
                // TODO: nothing
            } label: {
                Text("Cancel")
            }
        } message: { options in
            let messge = alertOption?.messge ?? ""
            
            if case .finishWorkout = options {
                EmptyView()
            } else {
                Text(messge)
            }
        }
        // Add Selected Exercises to the workout
        .onReceive(exerciseSelector.signal) { templates in
            
            withCustomSpring {
                
                insertWorkoutIfRequired()
                
                for template in templates {
                    let exercise = Exercise()
                    workout.exercises.append(exercise)
                    exercise.template = template
                    exercise.repCountUnit = template.preferredRepCountUnit()
                    exercise.workout = workout
                    template.frequency += 1 // Improving the search results
                }
            }
        }
        .onReceive(appState.signal){ message in
            switch message {
            case .openWorkout(let workoutToOpen):
                guard isWorkoutInProgress.not() else {
                    alertOption = .openAnotherWorkout(workoutToOpen)
                    return
                }   // return is current workout is in progress
                workout = workoutToOpen
                isWorkoutSaved = true
                appState.send(.openEditWorkoutSheet)
                viewModel.resume(workout: workout)
            default:
                break
            }
        }
        .navigationDestination(for: RouterDestination.self) { dest in
            switch dest {
            case .listExercise:
                ListTemplateView(messageQueue: exerciseSelector, canSelect: true, searchString: searchText)
                    .searchable(text: $searchText)
                    .environment(routerPath)
            default:
                EmptyView()
            }
        }
    }
    
    private func finish() {
        insertWorkoutIfRequired()
        workout.endDate = .now
        workout.duration = workout.startDate.distance(to: .now)
        isWorkoutSaved = false
        isWorkoutInProgress = false
        appState.send(.closeWorkoutEditor)
        workout = Workout()
        viewModel.reset()
    }
    
    private func insertWorkoutIfRequired() {
        if !isWorkoutSaved {
            modelContext.insert(workout)
            isWorkoutSaved = true
            viewModel.resume(workout: workout)
        }
        isWorkoutInProgress = true
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
        let isWorkoutInvalid = workout.exercises.first { exercise in
            exercise.reps.first { set in
                !isValid(set: set, forExercise: exercise)
            } != nil
        } != nil
        return !isWorkoutInvalid
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

#Preview {
    @State var selectedDetent: PresentationDetent = .ExpandedSheetDetent
    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    
    return WorkoutEditorBottomSheetView(viewModel: viewModel, selectedDetent: $selectedDetent)
        .withPreviewEnvironment()
}

fileprivate extension WorkoutEditorView {
    @ViewBuilder
    private var emptyStateView: some View {
        GeometryReader { proxy in
            VStack(alignment: .center) {
                Image(.emptyState)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Text("There are no exercises.\nKindly add exercises to see your progress")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .frame(width: proxy.size.width, height: proxy.size.width)
        }
    }
}
