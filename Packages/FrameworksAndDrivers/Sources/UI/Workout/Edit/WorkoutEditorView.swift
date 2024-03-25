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
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.keyboardShowing) private var keyboardShowing
    @Environment(RouterPath.self) private var routerPath

    @State private var exerciseSelector: ConcreteMessageQueue<[ExerciseBluePrint]> = .init()
    @State private var alertOption: AlertOption?
    @State private var showFinishWorkoutAlert: Bool = false
    @State private var searchText = ""
    
    @Bindable var store: StoreOf<WorkoutEditorFeature>
    
    public var body: some View {
        ZStack {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    
                    LazyVStack(alignment: .leading) {
                        HStack {
                            TextField("Workout name", text: $store.workout.name.sending(\.nameChanged))
                                .font(.title3)
                            
                            Spacer()
                            
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
                        
                        Text("Notes")
                            .truncationMode(.tail)
                            .foregroundStyle(.tertiary)
                            .font(.body)
                            .onTapGesture {
                                Logger.ui.info("Add notes for workout: TODO: Pending implementation")
                            }
                        
                        if store.workout.exercises.isNotEmpty {
                            ExercisesListView(store: store.scope(state: \.exercisesList, action: \.exercisesList))
                        } else {
                            emptyStateView
                        }
                        
                    }
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.automatic)
                }
                
                Spacer()
                
                // MARK: - Add Exercise Action
                if !keyboardShowing {
                    Button(action: {
                        store.send(.showExerciseListButtonTapped, animation: .default)
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
                
                if (store.workout.exercises.isNotEmpty) && keyboardShowing == false {
                    HStack {
                        // MARK: - Cancel Action
                        Button(role: .destructive, action: {
                            store.send(.cancelButtonTapped)
                        }, label: {
                            Label("Cancel", systemImage: "trash.fill")
                                .padding(.horizontal)
                        })
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)
                        .foregroundStyle(.primary)
                        
                        Button(action: {
                            store.send(.finishButtonTapped)
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
        // TODO: Alerts
//        .alert(alertOption?.titile ?? "Alert", isPresented: $showFinishWorkoutAlert, presenting: alertOption) { options in
//            Button(action: {
//                if case .openAnotherWorkout(let workoutToOpen) = options {
//                    workout = workoutToOpen
//                    isWorkoutSaved = true
//                    isWorkoutInProgress = false
//                    appState.send(.openEditWorkoutSheet)
//                    viewModel.resume(workout: workout)
//                } else {
//                    finish()
//                }
//            }) {
//                Text("Yes")
//            }
//            Button(role: .cancel) {
//                // TODO: nothing
//            } label: {
//                Text("Cancel")
//            }
//        } message: { options in
//            let messge = alertOption?.messge ?? ""
//            
//            if case .finishWorkout = options {
//                EmptyView()
//            } else {
//                Text(messge)
//            }
//        }

        // TODO: Handle workout resume
//        .onReceive(appState.signal){ message in
//            switch message {
//            case .openWorkout(let workoutToOpen):
//                guard isWorkoutInProgress.not() else {
//                    alertOption = .openAnotherWorkout(workoutToOpen)
//                    return
//                }   // return is current workout is in progress
//                workout = workoutToOpen
//                isWorkoutSaved = true
//                appState.send(.openEditWorkoutSheet)
//                viewModel.resume(workout: workout)
//            default:
//                break
//            }
//        }
    }
    
//    private func finish() {
//        insertWorkoutIfRequired()
//        workout.endDate = .now
//        workout.duration = workout.startDate.distance(to: .now)
//        isWorkoutSaved = false
//        isWorkoutInProgress = false
//        appState.send(.closeWorkoutEditor)
//        workout = Workout()
//        viewModel.reset()
//    }
    
//    private func insertWorkoutIfRequired() {
//        if !isWorkoutSaved {
//            modelContext.insert(workout)
//            isWorkoutSaved = true
//            viewModel.resume(workout: workout)
//        }
//        isWorkoutInProgress = true
//    }
//    
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

//#Preview {
//    @State var selectedDetent: PresentationDetent = .ExpandedSheetDetent
//    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
//    
//    return WorkoutEditorBottomSheetView(viewModel: viewModel, selectedDetent: $selectedDetent)
//        .withPreviewEnvironment()
//}

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
