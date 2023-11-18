//
//  Router.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 17/11/23.
//

import SwiftUI
import Foundation
import Observation
import Combine

/// Navigation view for Router (NavigationStack)
public enum RouterDestination: Hashable {
    case workoutDetails
    case exerciseList
}

/// View for Sheets
public enum SheetDestination: Identifiable {
    case recordWorkout
    
    public var id: String {
        String(describing: self)
    }
}


@MainActor
@Observable final class RouterPath {
    public var path: [RouterDestination] = []
    public var presentedSheet: SheetDestination?
    
    public init() {}
    
    public func navigate(to: RouterDestination) {
        path.append(to)
    }
}

@MainActor
extension View {
    func withAppRouter() -> some View {
        navigationDestination(for: RouterDestination.self) { destination in
            switch destination {
            case .workoutDetails:
                Text("Workout Details")
            case .exerciseList:
                Text("Show Exercise List")
            }
        }
    }
    
    func withSheetDestinations(sheetDestinations: Binding<SheetDestination?>) -> some View {
        sheet(item: sheetDestinations) { destination in
            switch destination {
            case .recordWorkout:
                Text("Show Record Sheet Here")
            }
        }
    }
}
