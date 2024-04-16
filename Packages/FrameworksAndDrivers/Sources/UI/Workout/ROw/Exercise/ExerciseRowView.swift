//
//  ExerciseRowView.swift
//
//
//  Created by harsh vishwakarma on 13/12/23.
//

import Domain
import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import ComposableArchitecture

@Reducer
public struct ExerciseRow {
    @Reducer(state: .equatable)
    public enum Destination {
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        
        @CasePathable
        public enum ConfirmationDialog {
            case confirmDelete
            case cancelDelete
        }
    }
    
    @ObservableState
    public struct State: Equatable, Identifiable {
        @Presents var destination: Destination.State?
        
        public var id: ObjectIdentifier {
            exercise.id
        }
        var exercise: Exercise
    }
    
    public enum Action {
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)

        case deleteButtonTapped

        public enum Delegate {
            case addNewSet
            case editSet(Rep)
            case delete
            case showBluePrintDetails
        }
    }
    
    // TODO: Move Delete Exercise action here
    public var body: some ReducerOf<Self> {
        Reduce {state, action in
            switch action {
            case .deleteButtonTapped:
                state.destination = .confirmationDialog(.delete)
                return .none
                
            case let .destination(.presented(.confirmationDialog(dialog))):
                switch dialog {
                case .confirmDelete:
                    return .send(.delegate(.delete))
                case .cancelDelete:
                    return .none
                }
            case .destination:
                return .none
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

public struct ExerciseRowView: View {
    @Bindable var store: StoreOf<ExerciseRow>
    
    @State private var showExpandedSetView = true
    
    var isEditable: Bool
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                ExerciseRowHeaderView(store: store, isExpanded: $showExpandedSetView)
                    .padding(.bottom, 4)
                
                ForEachWithIndex(store.exercise.reps) { idx, rep in
                    ExerciseRepRowView(set: rep, position: idx)
                        .transition(.move(edge: .bottom))
                        .onTapGesture {
                            store.send(.delegate(.editSet(rep)))
                        }
                }
                
                if store.exercise.reps.isNotEmpty {
                    HStack {
                        Text("\(store.exercise.repCountUnit.description)")
                            .font(.caption2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("kg")  // TODO: Get the default unit set for this exercise
                            .font(.caption2)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 8)
                    }
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .bottom))
                }
            }
            .padding(.listRowContentInset)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.tertiary, lineWidth: 0.5)
                    .fill(.background)
                    .padding(0.5)
            }
            
            // Footer
            ExerciseRowFooterView(store: store, isEditable: isEditable)
                .zIndex(-1)
        }
        .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
    }
}

// TODO: Pending
extension ConfirmationDialogState where Action == ExerciseRow.Destination.ConfirmationDialog {
    static var delete = Self {
        TextState("Delete Exercise?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmDelete) {
            TextState("Yes")
        }
        ButtonState(role: .cancel, action: .cancelDelete) {
            TextState("Nevermind")
        }
    } message: {
        TextState("Are you sure you want to delete this exercise?")
    }
}
