//
//  ListExerciseView.swift
//  
//
//  Created by harsh vishwakarma on 13/11/23.
//

import SwiftUI
import Domain

@MainActor
public struct ListExerciseView: View {
    
    @State var viewModel: ListExerciseViewModel
    
    public init(viewModel: ListExerciseViewModel) {
        self._viewModel = .init(initialValue: viewModel)
    }
    
    public var body: some View {
        List(viewModel.exercies) {
            Text($0.name)
        }
        .task {
            await viewModel.listExercises()
        }
    }
}
