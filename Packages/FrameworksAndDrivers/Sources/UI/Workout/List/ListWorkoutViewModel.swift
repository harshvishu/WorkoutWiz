//
//  SwiftUIView.swift
//  
//
//  Created by harsh vishwakarma on 23/12/23.
//

import Observation
import Domain
import ApplicationServices
import Persistence
import Foundation
import DesignSystem
import SwiftData
import OSLog

@Observable
final class ListWorkoutViewModel {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: ListWorkoutViewModel.self))
    
    private(set) var viewState: ViewState = .loading

    private var filter: ListWorkoutFilter
    private var listWorkoutUseCase: ListWorkoutIOPort?
    private var messageQueue: ConcreteMessageQueue<[WorkoutRecord]>?
    private var workouts: [WorkoutRecord] = []

    public init(
        filter: ListWorkoutFilter = .none,
        listWorkoutUseCase: ListWorkoutIOPort? = nil
    ) {
        self.filter = filter
        self.listWorkoutUseCase = listWorkoutUseCase
    }
    
    
    func listWorkouts() async {
        do {
            let workouts = try await listWorkoutUseCase?.listWorkouts(filter) ?? []
            self.workouts = workouts
            viewState = workouts.isNotEmpty ? .display(records: workouts) : .empty
            logger.info("\(workouts.count) workouts fetched")
        } catch {
            logger.error("\(error)")
        }
    }
    
    func bind(listWorkoutUseCase: ListWorkoutIOPort? = nil) {
        logger.info("Set ListWorkoutUseCase")
        self.listWorkoutUseCase = listWorkoutUseCase
    }
    
    func set(filter: ListWorkoutFilter) {
        self.filter = filter
        // TODO: Reset the view state
    }
    
    func delete(at offsets: IndexSet) async {
        if case .display(var workouts) = self.viewState {
            let workoutsToDelete = offsets.map({workouts[$0]})
            do {
                let status = try await listWorkoutUseCase?.deleteWorkouts(workoutsToDelete) ?? false
                if status {
                    workouts.remove(atOffsets: offsets)
                    self.viewState = .display(records: workouts )
                } else {
                    await listWorkouts()
                }
            } catch {
                logger.error("\(error)")
            }
        }
    }
}

extension ListWorkoutViewModel {
    enum ViewState {
//        public enum PagingState {
//            case hasNextPage, loadingNextPage, none
//        }
        
        case loading
        case empty
        case display(records: [WorkoutRecord])
//        case error(error: Error)
    }
}
