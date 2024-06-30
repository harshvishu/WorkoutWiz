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
        // Enum to represent different destinations, specifically confirmation dialogs in this case
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        
        @CasePathable
        public enum ConfirmationDialog {
            // Enum to represent different actions within the confirmation dialog
            case confirmDelete
            case cancelDelete
        }
    }
    
    @ObservableState
    public struct State: Equatable, Identifiable {
        @Presents var destination: Destination.State?
        
        // Property to return the unique identifier for the exercise
        public var id: ObjectIdentifier {
            exercise.id
        }
        // Property to hold the exercise data
        var exercise: Exercise
    }
    
    public enum Action {
        
        // Action to handle delegation of tasks to an external handler or parent component.
        // The associated value is of type `Delegate`, which contains specific delegate actions.
        case delegate(Delegate)

        // Action to handle navigation or presentation-related tasks.
        // The associated value is of type `PresentationAction<Destination.Action>`, which encapsulates actions for presenting a destination.
        case destination(PresentationAction<Destination.Action>)

        // Action triggered when the delete button is tapped by the user.
        // This action typically leads to presenting a confirmation dialog to confirm the delete action.
        case deleteButtonTapped

        public enum Delegate {
            // Enum to represent delegate actions, which are actions that should be handled by an external handler or parent component.
            
            // Delegate action to add a new set to the exercise.
            // This could trigger the presentation of a form to input the details of the new set.
            case addNewSet
            
            // Delegate action to edit an existing set.
            // The associated value is of type `Rep`, which represents the set to be edited.
            // This could open a form pre-filled with the details of the selected set.
            case editSet(Rep)
            
            // Delegate action to delete the current exercise.
            // This action is typically confirmed via a confirmation dialog before being executed.
            case delete
            
            // Delegate action to show the details of the exercise template.
            // This action might open a detailed view or modal with information about the exercise template.
            case showTemplateDetails
        }
    }
    
    // TODO: Move Delete Exercise action here
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // When the delete button is tapped, present the confirmation dialog
            case .deleteButtonTapped:
                state.destination = .confirmationDialog(.delete)
                return .none
                
            // Handle actions within the confirmation dialog
            case let .destination(.presented(.confirmationDialog(dialog))):
                switch dialog {
                // If the user confirms delete, send the delete delegate action
                case .confirmDelete:
                    return .send(.delegate(.delete))
                // If the user cancels delete, do nothing
                case .cancelDelete:
                    return .none
                }
            // Handle other destination actions (not used in this example)
            case .destination:
                return .none
            // Handle delegate actions (not used in this example)
            case .delegate:
                return .none
            }
        }
        // Apply the reducer for the destination state
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
                        .transition(.opacity)
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
