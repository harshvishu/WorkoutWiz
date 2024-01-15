//
//  WorkoutEditorExerciseListView.swift
//
//
//  Created by harsh vishwakarma on 25/12/23.
//

import Domain
import SwiftUI
import DesignSystem
import Persistence
import ApplicationServices
import SwiftData
import OSLog

struct WorkoutEditorExerciseListView: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: WorkoutEditorExerciseListView.self))
    
    @Environment(WorkoutEditorViewModel.self) private var viewModel
    @Environment(RouterPath.self) private var routerPath
    
    var body: some View {    
        @Bindable var viewModel = viewModel
        
        Section {
            // TODO: replace with an enum to handle the states
            
            if viewModel.workout.exercises.isEmpty {
               emptyStateView
            } else {
                ForEach(viewModel.workout.exercises) {
                    ExerciseSetRowView(exercise: $0)
//                                .environment(viewModel)
                }
            }
            
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.listRowInset)
    }
}

fileprivate extension WorkoutEditorExerciseListView {
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

#Preview {
    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    return WorkoutEditorExerciseListView()
        .withPreviewEnvironment()
        .environment(viewModel)
}
