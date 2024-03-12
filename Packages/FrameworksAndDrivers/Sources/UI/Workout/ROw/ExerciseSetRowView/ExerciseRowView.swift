//
//  ExerciseRowView.swift
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


public struct ExerciseRowView: View {
    var exercise: Exercise
    
    @State private var showExpandedSetView = true
    @State private var messageQueue: ConcreteMessageQueue<(Rep,Int)> = .init()
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                ExerciseRowHeaderView(exerciseName: exercise.template?.name ?? "", isExpanded: $showExpandedSetView)
                    .padding(.bottom, 4)
                
                // Sets
//                Group {
                    // Show all exercise reps
                    ForEach(exercise.reps) { set in
                        ExerciseRepRowView(set: set, position: set.position)
                            .transition(.move(edge: .bottom))
                            .onTapGesture {
                                
                                // TODO: 
//                                appState.send(.popup(.editSetForExercise(exercise, set)))
                            }
                    }
                    
                    // TODO: Use this instead 
                if exercise.reps.isNotEmpty {
                    HStack {
                        Text("\(exercise.repCountUnit.description)")
                            .font(.caption2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("kg")  // TODO: Get the default unit set for this exercise
                            .font(.caption2)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 8)
                    }
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .bottom))
                }
//                }
            }
            .padding(.listRowContentInset)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.tertiary, lineWidth: 0.5)
                    .fill(.background)
                    .padding(0.5)
            }
            
            // Footer
            ExerciseRowFooterView(exercise: exercise)
                .zIndex(-1)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(.listRowInset)
    }
}

//#Preview {
//    let exerciseID = UUID()
//    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
//    
//    return List {
//        ExerciseSetRowView(
//            exercise: ExerciseRecord(
//                documentID: "1234",
//                workoutDocumentID: "1111",
//                template: ExerciseTemplate.mock_1,
//                sets: [ExerciseSetRecord(
//                    workoutDocumentID: "1",
//                    exerciseDocumentID: "1_2",
//                    weight: 15.5,
//                    type: .rep,
//                    time: 0.0,
//                    rep: 10,
//                    failure: true,
//                    calories: 2.5,
//                    position: 1
//                )]
//            )
//        )
//    }
//    .listRowSpacing(.listRowVerticalSpacing)
//    .withPreviewEnvironment()
//    .environment(viewModel)
//}
