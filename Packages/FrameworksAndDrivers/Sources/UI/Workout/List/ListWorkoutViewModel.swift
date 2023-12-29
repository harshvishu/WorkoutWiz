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
    
    private var listWorkoutUseCase: ListWorkoutIOPort?
    private var messageQueue: ConcreteMessageQueue<[WorkoutRecord]>?
    private(set) var viewState: ViewState = .loading
    
    public init(
        listWorkoutUseCase: ListWorkoutIOPort? = nil
    ) {
        self.listWorkoutUseCase = listWorkoutUseCase
    }
    
//    public private(set) var workouts: [WorkoutRecord] = []
    
    func listWorkouts() async {
        do {
            let workouts = try await listWorkoutUseCase?.listWorkouts() ?? []
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
