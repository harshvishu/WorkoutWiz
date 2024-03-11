//
//  SwiftDataWorkoutRepository.swift
//
//
//  Created by harsh vishwakarma on 20/11/23.
//

import Foundation
import Domain
import ApplicationServices
import SwiftData
import OSLog

public enum ListWorkoutFilter {
    case none
    case today(limit: Int? = nil)
    case date(Date, limit: Int? = nil)
    case dates(date1: Date, date2: Date, limit: Int? = nil)
    case count(Int)
}

func fetchDescriptor(filterByID ID: UUID, fetchLimit limit: Int?) -> FetchDescriptor<Workout> {
    var descriptor = FetchDescriptor<Workout>(predicate: #Predicate {
        $0.id == ID
    })
    descriptor.fetchLimit = limit
    return descriptor
}

func fetchDescriptorForWorkout(filter: ListWorkoutFilter) -> FetchDescriptor<Workout> {
    var descriptor = FetchDescriptor<Workout>()
    switch filter {
    case .none:
        break
    case .today(let limit):
        descriptor.predicate = predicate(start: Date(), end: Date())
        if let limit = limit {
            descriptor.fetchLimit = limit
        }
    case .date(let date, let limit):
        descriptor.predicate = predicate(start: date, end: date)
        if let limit = limit {
            descriptor.fetchLimit = limit
        }
    case .dates(let date1, let date2, let limit):
        descriptor.predicate = predicate(start: date1, end: date2)
        if let limit = limit {
            descriptor.fetchLimit = limit
        }
    case .count(let count):
        descriptor.fetchLimit = count
    }
    return descriptor
}

func predicate(
    start: Date,
    end: Date
) -> Predicate<Workout> {
    let calendar = Calendar.autoupdatingCurrent
    let start = calendar.startOfDay(for: start)
    let end = calendar.date(byAdding: .init(day: 1), to: calendar.startOfDay(for: end)) ?? end
    
    return #Predicate<Workout> {
        $0.startDate > start && $0.startDate < end
    }
}
