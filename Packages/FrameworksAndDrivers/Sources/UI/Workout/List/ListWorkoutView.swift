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
    @Environment(RouterPath.self) var routerPath
    @Environment(AppState.self) private var appState
    
    @State var viewModel: ListWorkoutViewModel
    
    @Query(sort: [SortDescriptor(\Workout.startDate, order: .reverse)], transaction: Transaction(animation: .easeInOut)) var workouts: [Workout]
    @State private var viewState: ViewState = .loading
    
    public init(
        filter: ListWorkoutFilter,
        grouping: Bool
    ) {
        self._viewModel = .init(
            initialValue: ListWorkoutViewModel(filter: filter, grouping: grouping)
        )
    }
    
    var body: some View {
            
            Section {
                
                ForEach(workouts, id: \.id) { workout in
                    WorkoutRowView(workout: workout)
                        .onTapGesture {
                            appState.send(.openWorkout(workout))
                        }
                }
                .onDelete(perform: delete)
                
                Button(action: {
                    appState.send(.openEditWorkoutSheet)
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
                .opacity(workouts.isEmpty ? 1 : 0)
                
            } header: {
                HStack {
                    Text("Today")
                    
                    Spacer()
                    
                    Button {
                        appState.send(.showLogs)
                    } label: {
                        Text("All Entries")
                    }
                    .foregroundStyle(.primary)
                }
            }
            .listRowSeparator(.hidden)
            
            /*
             switch viewState {
             case .loading:
                ProgressView()
                    .task {
                        bindModelContext()
                        await viewModel.listWorkouts()
                    }
            case .displayGrouped(let groupByDay):
                ForEach(groupByDay.sorted(by: { $0.key > $1.key }), id: \.key) { day, workouts in
                    Text(day, style: .date)
                        .id(day.formatted(.dateTime))
                        .print(day.formatted(.dateTime))
                    
                    ForEach(workouts, id: \.id) { workout in
                        WorkoutRowView(workout: workout)
                            .onTapGesture {
                                routerPath.navigate(to: .workoutDetails(workout: workout))
                            }
                        //                        .id($0.documentID)
                    }
                    .onDelete(perform: delete)
                }
                .onReceive(appState.signal) {
                    if case .workoutFinished = $0 {
                        Task {
                            await viewModel.listWorkouts()
                        }
                    }
                }
            case .display(let workouts):
                Section {
                    ForEach(workouts, id: \.id) { workout in
                        WorkoutRowView(workout: workout)
                            .onTapGesture {
                                appState.send(.openWorkout(workout))
                            }
                    }
                    .onDelete(perform: delete)
                    
                } header: {
                    // TODO: Change header based on data
                    HStack {
                        Text("Today")
                        
                        Spacer()
                        
                        Button {
                            appState.send(.showLogs)
                        } label: {
                            Text("All Entries")
                            // TODO: Fixme Should not be seen in Calnedar View
                        }
                        .foregroundStyle(.primary)
                    }
                    .foregroundStyle(.primary)
                    .font(.headline)
                }
                .onReceive(appState.signal) {
                    if case .workoutFinished = $0 {
                        Task {
                            await viewModel.listWorkouts()
                        }
                    }
                }
            case .empty:
                Section {
                    Button(action: {
                        appState.send(.openEditWorkoutSheet)
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
                            appState.send(.showLogs)
                        } label: {
                            Text("All Entries")
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .listRowSeparator(.hidden)
                .onReceive(appState.signal) {
                    if case .workoutFinished = $0 {
                        Task {
                            await viewModel.listWorkouts()
                        }
                    }
                }
            }
            */
    }
}

fileprivate extension ListWorkoutView {
    func delete(at indexSet: IndexSet) {
        for index in indexSet {
            let workout = workouts[index]
            modelContext.delete(workout)
        }
    }
}

#Preview {    
    return ListWorkoutView(filter: .none, grouping: false)
        .withPreviewEnvironment()
}

fileprivate enum ViewState {
    case loading
    case empty
    case display(records: [Workout])
    case displayGrouped(records: [Date : [Workout]])
}
