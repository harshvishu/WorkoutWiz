//
//  EditWorkoutExercisesListView.swift
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

struct EditWorkoutExercisesListView: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: EditWorkoutExercisesListView.self))
    
    @Binding var viewModel: EditWorkoutViewModel
    @Binding var routerPath: RouterPath
    
    var body: some View {
        VStack {
            List {
                Section {
                    // TODO: replace with an enum to handle the states
                    
                    VStack(alignment: .leading) {
                        HStack {
                            TextField("Workout name", text: $viewModel.workout.name ?? "")
                                .font(.title3)
                            
                            Spacer()
                            
                            // TODO: Use tags & a dropdown
                            Label("Pull", systemImage: "dumbbell")
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(in: .capsule)
                                .backgroundStyle(.tertiary)
                                .clipShape(.capsule)
                        }
                        
                        TextField("Notes", text: $viewModel.workout.notes ?? "")
                            .font(.body)
                    }
                    
                    if viewModel.workout.exercises.isEmpty {
                       emptyStateView
                    } else {
                        ForEach(viewModel.workout.exercises) {
                            ExerciseSetRowView(exercise: $0, recordWorkoutViewModel: viewModel)
//                                .environment(viewModel)
                        }
                    }
                    
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
    }
}

fileprivate extension EditWorkoutExercisesListView {
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
    @State var viewModel = EditWorkoutViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    @State var saveDataManager = SaveDataManager(saveDataUseCase: SaveDataUseCase(saveDataRepository: UserDefaultsSaveDataRepository()))
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    @State var routerPath: RouterPath = .init()
    
    return EditWorkoutExercisesListView(viewModel: $viewModel, routerPath: $routerPath)
        .withPreviewModelContainer()
        .environment(globalMessageQueue)
        .environment(saveDataManager)
}
