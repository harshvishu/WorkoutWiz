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
        filter: ListWorkoutFilter,
        grouping: Bool
    ) {
        self._viewModel = .init(
            initialValue: ListWorkoutViewModel(filter: filter, grouping: grouping)
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
        case .displayGrouped(let groupByDay):
            ForEach(groupByDay.sorted(by: { $0.key > $1.key }), id: \.key) { day, workouts in
//                Section {
                    Text(day, style: .date)
                    .id(day.formatted(.dateTime))
                    .print(day.formatted(.dateTime))
                    
                    ForEach(workouts) {
                        WorkoutRowView(workout: $0)
                            .id($0.documentID)
                    }
                    .onDelete(perform: delete)
                    
//                } header: {
//                    Text(day, style: .date)
//                }
                
            }
            .onReceive(globalMessageQueue.signal) {
                if case .workoutFinished = $0 {
                    Task {
                        await viewModel.listWorkouts()
                    }
                }
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
                    .foregroundStyle(.primary)
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
            } header: {
                HStack {
                    Text("Today")
                    
                    Spacer()
                    
                    Button {
                        globalMessageQueue.send(.openEditWorkoutSheet)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .foregroundStyle(.primary)
                }
            }
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
    
    return ListWorkoutView(filter: .none, grouping: false)
        .environment(globalMessageQueue)
        .withPreviewModelContainer()
}
