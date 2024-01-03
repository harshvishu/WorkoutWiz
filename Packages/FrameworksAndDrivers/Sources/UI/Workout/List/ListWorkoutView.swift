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
            Section {
                ForEach(workouts) {
                    WorkoutRowView(workout: $0)
                }
            } header: {
                HStack {
                    Text("Recents")
//                        .font(.headline)
//                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                        globalMessageQueue.send(.showLogs)
                    } label: {
                        Text("View All")
                    }
                    .buttonStyle(.plain)
                }
//                .font(.headline)
                .foregroundStyle(.secondary)
            }
            .onChange(of: isPresented) { _, isPresented in
                //            if !isPresented {
                //                viewModel.didSelect(exercises: getSelectedExercises())
                //            }
            }
            .onReceive(globalMessageQueue.signal) {
                if case .workoutFinished = $0 {
                    Task {
                        await viewModel.listWorkouts()
                    }
                }
            }
        case .empty:
            Button(action: {
                globalMessageQueue.send(.openEditWorkoutSheet)
            }, label: {
                VStack {
                    Text("No workouts yet!\nTap to add a workout")
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            })
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .onReceive(globalMessageQueue.signal) {
                if case .workoutFinished = $0 {
                    Task {
                        await viewModel.listWorkouts()
                    }
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
