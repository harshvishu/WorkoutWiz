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
    
    public init(
        filter: ListWorkoutFilter
    ) {
        self._viewModel = .init(
            initialValue: ListWorkoutViewModel(filter: filter)
        )
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
                .onDelete(perform: delete)
            } header: {
                // TODO: Change header based on data
                HStack {
                    Text("Today")
                    
                    Spacer()
                    
                    Button {
                        globalMessageQueue.send(.openEditWorkoutSheet)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                }
                .foregroundStyle(.primary)
                .font(.headline)
            }
            .onReceive(globalMessageQueue.signal) {
                if case .workoutFinished = $0 {
                    Task {
                        await viewModel.listWorkouts()
                    }
                }
            }
        case .empty:
            Section {
                HStack {
                    Text("Today")
                        .foregroundStyle(.primary)
                        .font(.title3.bold())
                    
                    Spacer()
                    
                    Button {
                        globalMessageQueue.send(.openEditWorkoutSheet)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                }
                
                Button(action: {
                    globalMessageQueue.send(.openEditWorkoutSheet)
                }, label: {
                    VStack {
                        Text("No workouts for today!")
                            .font(.title3)
                            Text("Tap to start a workout")
                                .font(.headline)
                    }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                })
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
//            .listRowBackground(Color.clear)
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
    
    func delete(at offsets: IndexSet) {
        Task {
            await viewModel.delete(at: offsets)
        }
    }
}

#Preview {
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return ListWorkoutView(filter: .none)
        .environment(globalMessageQueue)
        .withPreviewModelContainer()
}
