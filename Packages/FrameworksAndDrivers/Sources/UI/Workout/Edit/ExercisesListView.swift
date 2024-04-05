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
        case delete(exercise: ExerciseRow.State)
        
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case delete(exercise: ExerciseRow.State)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .delete(exercise):
                return .send(.delegate(.delete(exercise: exercise)))
            case .exercises:
                return .none
            case .delegate:
                return .none
            }
        }
        .forEach(\.exercises, action: \.exercises) {
            ExerciseRow()
        }
    }
}

struct ExercisesListView: View {
    let store: StoreOf<ExercisesList>
    var isEditable: Bool
    
    var body: some View {
        ForEach(store.scope(state: \.exercises, action: \.exercises)) {
            ExerciseRowView(store: $0, isEditable: isEditable)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.listRowContentInset)
            }
            .onDelete(perform: delete)
    }
    
    func delete(at indexSet: IndexSet) {
        for index in indexSet {
            let exercise = store.exercises[index]
            store.send(.delete(exercise: exercise))
        }
    }
}

#Preview {
    ExercisesListView(store: StoreOf<ExercisesList>(initialState: ExercisesList.State(), reducer: {
        ExercisesList()
    }), isEditable: true)
}
