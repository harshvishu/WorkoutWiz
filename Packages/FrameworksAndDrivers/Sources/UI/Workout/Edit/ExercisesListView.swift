//
//  WorkoutEditorExerciseListView.swift
//
//
//  Created by harsh vishwakarma on 25/12/23.
//

import Domain
import SwiftUI
import DesignSystem
import Persistence
import ApplicationServices
import SwiftData
import ComposableArchitecture

@Reducer
public struct ExercisesList {
    @ObservableState
    public struct State: Equatable {
        var exercises: IdentifiedArrayOf<ExerciseRow.State> = []
    }
    
    public enum Action {
        case exercises(IdentifiedActionOf<ExerciseRow>)
    }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
            .forEach(\.exercises, action: \.exercises) {
                ExerciseRow()
            }
    }
}

struct ExercisesListView: View {
    let store: StoreOf<ExercisesList>
    
    var body: some View {
        Section {
            // TODO: replace with an enum to handle the states
            if store.exercises.isEmpty  {
                emptyStateView
            } else {
                ForEach(store.scope(state: \.exercises, action: \.exercises)) {
                    ExerciseRowView(store: $0)
                }
            }
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.listRowInset)
    }
}

fileprivate extension ExercisesListView {
    @ViewBuilder
    private var emptyStateView: some View {
        GeometryReader { proxy in
            VStack(alignment: .center) {
                Image(.emptyState)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Text("There are no exercises.\nKindly add exercises to see your progress")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .frame(width: proxy.size.width, height: proxy.size.width)
        }
    }
}

#Preview {
    ExercisesListView(store: StoreOf<ExercisesList>(initialState: ExercisesList.State(), reducer: {
        ExercisesList()
    }))
}
