//
//  ListWorkoutView.swift
//
//
//  Created by harsh vishwakarma on 23/12/23.
//

import SwiftUI
import Domain
import ApplicationServices
import Persistence
import DesignSystem
import OSLog
import SwiftData

struct ListWorkoutView: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ListWorkoutView.self))
    
    @Environment(\.isPresented) var isPresented
    @Environment(\.modelContext) private var modelContext
    @Environment(ConcreteMessageQueue<ApplicationMessage>.self) private var globalMessageQueue
    
    @State var viewModel: ListWorkoutViewModel
    
    public init(viewModel: ListWorkoutViewModel = ListWorkoutViewModel()) {
        self._viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView()
                .task {
                    bindModelContext()
                    await viewModel.listWorkouts()
                }
        case .display(let workouts):
            ForEach(workouts) {
                WorkoutRowView(workout: $0)
                    .id($0.id)
                    .listRowSeparator(.hidden)
            }
            .onChange(of: isPresented) { _, isPresented in
    //            if !isPresented {
    //                viewModel.didSelect(exercises: getSelectedExercises())
    //            }
            }
            .onReceive(globalMessageQueue.signal) {
                if case .workout = $0 {
                    Task {
                        await viewModel.listWorkouts()
                    }
                }
            }
        case .empty:
            VStack {
                Text("No workouts yet!")
                Button("Tap to add a workout") {
                    globalMessageQueue.send(.openEditWorkoutSheet)
                }
            }
        }
    }
}

fileprivate extension ListWorkoutView {
    func bindModelContext() {
        viewModel.bind(listWorkoutUseCase: ListWorkoutUseCase(workoutRepository: SwiftDataWorkoutRepository(modelContext: modelContext)))
    }
}

#Preview {
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return ListWorkoutView()
        .environment(globalMessageQueue)
        .withPreviewModelContainer()
}


//public enum StatusesState {
//  public enum PagingState {
//    case hasNextPage, loadingNextPage, none
//  }
//
//  case loading
//  case display(statuses: [Status], nextPageState: StatusesState.PagingState)
//  case error(error: Error)
//}
