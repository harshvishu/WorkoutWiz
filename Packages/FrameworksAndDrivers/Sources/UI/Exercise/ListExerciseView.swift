//
//  ListExerciseView.swift
//  
//
//  Created by harsh vishwakarma on 13/11/23.
//

import SwiftUI
import Domain
import ApplicationServices
import Persistence

@MainActor
public struct ListExerciseView: View {
    
    @State var viewModel: ListExerciseViewModel
    
    public init(viewModel: ListExerciseViewModel = ListExerciseViewModel()) {
        self._viewModel = .init(initialValue: viewModel)
    }
    
    public var body: some View {
        List(viewModel.exercies) {
            Text($0.name)
        }
        .debugBorder()
        .task(priority: .background) {
            await viewModel.listExercises()
        }
    }
}

#Preview {
    ListExerciseView(viewModel: ListExerciseViewModel(listExerciseUseCase: ListExerciseUseCase(exerciseRepository: PreviewExerciseRepository())))
}

#if DEBUG
fileprivate class PreviewExerciseRepository: ExerciseRepository {
    func fetchExercises() async -> [Exercise] {
        let exersices : [Exercise] = [
//            Exercise(name: "Lat Pull Down", caloriesPerSecond: 0.025, tags: ["Back", "Pull"]),
//            Exercise(name: "Cable Row (Close Grip)", caloriesPerSecond: 0.020, tags: ["Back", "Pull"]),
//            Exercise(name: "Cable Row (Zig Zag) ", caloriesPerSecond: 0.015, tags: ["Back", "Pull"]),
//            Exercise(name: "Dead Lift", caloriesPerSecond: 0.30, tags: ["Back", "Pull", "Dumbell"]),
//            Exercise(name: "One Arm Dumbell Row", caloriesPerSecond: 0.015, tags: ["Back", "Pull", "Lats", "Dumbell"]),
        ]
        return exersices
    }
}
#endif
