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
    
    @Bindable var store: StoreOf<WorkoutEditorFeature>
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            //                ScrollView(.vertical, showsIndicators: false) {
            
            List {
                //                    LazyVStack(alignment: .leading) {
                HStack {
                    TextField("Workout name", text: $store.workout.name.sending(\.nameChanged))
                        .font(.title3)
                    
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
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: .defaultVerticalSpacing, leading: .defaultHorizontalSpacing, bottom: 0, trailing: .defaultHorizontalSpacing))
                
                Text("Notes")
                    .truncationMode(.tail)
                    .foregroundStyle(.tertiary)
                    .font(.body)
                    .onTapGesture {
                        // TODO:
                        Logger.ui.info("Add notes for workout: TODO: Pending implementation")
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: .defaultHorizontalSpacing, bottom: .defaultVerticalSpacing, trailing: .defaultHorizontalSpacing))
                
                if store.workout.exercises.isNotEmpty {
                    ExercisesListView(store: store.scope(state: \.exercisesList, action: \.exercisesList))
                } else {
                    emptyStateView
                        .listRowSeparator(.hidden)
                        .listRowInsets(.listRowContentInset)
                }
            }
            .listStyle(.inset)
            .listSectionSeparator(.hidden)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.automatic)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: .defaultVerticalSpacing) {
                    Divider()
                    
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
                    
                    if (store.workout.exercises.isNotEmpty) {
                        HStack {
                            // MARK: - Cancel Action
                            Button(role: .destructive, action: {
                                store.send(.cancelButtonTapped)
                            }, label: {
                                Label("Cancel", systemImage: "trash.fill")
                                    .padding(.horizontal)
                            })
//                            .buttonBorderShape(.capsule)
//                            .buttonStyle(.bordered)
                            .foregroundStyle(Color.red)
//                            .overlay(Capsule().stroke(Color.red, lineWidth: 2))
                            // TODO: Check for styling
                            
                            Button(action: {
                                store.send(.finishButtonTapped)
                            }, label: {
                                Text("Finish Workout")
                                    .frame(maxWidth: .infinity)
                            })
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.borderedProminent)
                            .tint(.primary)
                            .foregroundStyle(.background)
                        }
                        .padding(.horizontal, .defaultHorizontalSpacing)
                        .transition(.move(edge: .bottom))
                    }
                }
                .background(.ultraThinMaterial)
                .foregroundStyle(.primary)
                .opacity(keyboardShowing ? 0 : 1)
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
