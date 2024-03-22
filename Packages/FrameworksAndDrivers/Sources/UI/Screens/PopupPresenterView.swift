//
//  PopupPresenterView.swift
//
//
//  Created by harsh vishwakarma on 04/02/24.
//

import SwiftUI
import DesignSystem
import Domain
import ComposableArchitecture

struct EditRep {
    var exercise: Exercise?
    var rep: Rep?
}

struct AddRep {
    var exercise: Exercise?
}

@Reducer
public struct PopupPresenter {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)
        case repInput(RepInput)
        
        public enum Alert {
            case confirmDeletion
            case continueWithoutRecording
            case openSettings
        }
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State? = nil
    }
    
    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case addNewSet(toExercise: Exercise)
        case editSet(forExercise: Exercise, rep: Rep)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .addNewSet(exercise):
                state.destination = .repInput(RepInput.State(exercise: exercise))
                return .none
            case let .editSet(exercise, rep):
                state.destination = .repInput(RepInput.State(exercise: exercise, rep: rep))
                return .none
            case .destination(.presented(.repInput(.delegate(.close)))):
                state.destination = nil
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct PopupPresenterView: View {
    @Bindable var store: StoreOf<PopupPresenter>
    
    @Environment(\.keyboardShowing) var keyboardShowing
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
        }
        .sheet(item: $store.scope(state: \.destination?.repInput, action: \.destination.repInput)) { store in
            RepInputView(store: store)
                .presentationDetents([.medium])
                .presentationContentInteraction(.resizes)
        }
    }
}
