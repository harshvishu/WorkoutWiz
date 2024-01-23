//
//  ExerciseSetRowView.swift
//
//
//  Created by harsh vishwakarma on 13/12/23.
//

import Domain
import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(#file)")

public struct ExerciseSetRowView: View {
    @Environment(WorkoutEditorViewModel.self) private var editWorkoutViewModel
    
    @State private var exercise: ExerciseRecord
    @State private var showExpandedSetView = true
    
    @State private var messageQueue: ConcreteMessageQueue<(ExerciseSet,Int)> = .init()
    
    init(exercise: ExerciseRecord) {
        self._exercise = .init(initialValue: exercise)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                RowHeaderView(editWorkoutViewModel: editWorkoutViewModel, exercise: $exercise, isExpanded: $showExpandedSetView)
                
                // Sets
                VStack(alignment: .leading, spacing: 8) {
                    if showExpandedSetView {
                        // Show all exercise sets
                        ForEachWithIndex(exercise.sets, id: \.self) { index, set in
                            SetView(set: set, position: index, messageQueue: messageQueue)
                                .task {
                                    logger.trace("Render SetView \(index)")
                                }
                        }
                    } else {
                        // Show Summary View
                        // TODO: Pending
                        Text("\(exercise.sets.count) sets. Max weight 7.5 Kg with Failure. Calories burned = \(exercise.estimatedCaloriesBurned(), specifier: "%0.02f") Cal")
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.leading, 8)
                .onReceive(messageQueue.signal) { set, position in
                    if let set = editWorkoutViewModel.updateSet(set) {
                        exercise.sets[position] = set
                    }
                }
            }
            .padding(.listRowContentInset)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.tertiary, lineWidth: 0.5)
                    .fill(.background)
                    .padding(0.5)
                    .onTapGesture {
                        // TODO: Open detailed view for editing
                    }
            }
            
            // Footer
            RowFooterView(editWorkoutViewModel: editWorkoutViewModel, exercise: $exercise)
                .zIndex(-1)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(.listRowInset)
        .task {
            logger.trace("Render ExerciseSetRowView")
        }
    }
}

#Preview {
    let exerciseID = UUID()
    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    
    return List {
        ExerciseSetRowView(exercise: ExerciseRecord(template: ExerciseTemplate.mock_1, sets: [ExerciseSet(exerciseID: exerciseID, weight: 5.5, type: .rep, duration: 0.0, rep: 10,failure: true, calories: 2.5)]))
        ExerciseSetRowView(exercise: ExerciseRecord(template: ExerciseTemplate.mock_1, sets: [ExerciseSet(exerciseID: exerciseID, weight: 15.5, type: .rep, duration: 0.0, rep: 10,failure: true, calories: 2.5)]))
        ExerciseSetRowView(exercise: ExerciseRecord(template: ExerciseTemplate.mock_1, sets: [ExerciseSet(exerciseID: exerciseID, weight: 135, type: .rep, duration: 0.0,rep: 10,failure: true, calories: 2.5)]))
        
    }
    .listRowSpacing(.listRowVerticalSpacing)
    .withPreviewEnvironment()
    .environment(viewModel)
}
