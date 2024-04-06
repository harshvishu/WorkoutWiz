//
//  WorkoutEditorBottomSheetView.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Domain
import SwiftUI
import DesignSystem
import Persistence
import ApplicationServices
import SwiftData
import OSLog
import ComposableArchitecture

struct WorkoutEditorBottomSheetView: View {
    
    // MARK: - Environment
    
    // Accesses the model context environment
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State Variables
    
    // Bindable store for managing the workout editor state
    @Bindable var store: StoreOf<WorkoutEditor>
    // Binding variable for the selected presentation detent
    @Binding var selectedDetent: PresentationDetent
    
    // MARK: - Initializer
    
    // Custom initializer to set the store and selectedDetent
    init(store: StoreOf<WorkoutEditor>, selectedDetent: Binding<PresentationDetent>) {
        self.store = store
        self._selectedDetent = selectedDetent
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            // Main content: WorkoutEditorView
            WorkoutEditorView(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(selectedDetent.isCollapsed ? 0 : 1)
                .scrollIndicators(.hidden)
                .toolbar {
                    // Top bar leading items
                    ToolbarItemGroup(placement: .topBarLeading) {
                        // WorkoutEditorSheetHeaderView
                        WorkoutEditorSheetHeaderView(store: store, selectedDetent: $selectedDetent)
                    }
                    
                    // Top bar trailing items
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        // Expand/Collapse button
                        Button(action: {
                            // Hides the keyboard
                            hideKeyboard()
                            // Sends a delegate action to expand or collapse the view
                            store.send(.delegate(selectedDetent.isCollapsed ? .expand : .collapse), animation: .default)
                        }, label: {
                            // Adjusts icon based on workout progress and selected detent state
                            if store.isWorkoutInProgress {
                                Image(systemName: "chevron.up")
                                    .foregroundStyle(.secondary)
                                    .rotationEffect(Angle(degrees: selectedDetent.isCollapsed ? 0 : 180))
                            } else {
                                Image(systemName: "plus")
                                    .foregroundStyle(.secondary)
                                    .rotationEffect(Angle(degrees: selectedDetent.isCollapsed ? 0 : 360 + 45))
                            }
                        })
                        .foregroundStyle(.primary)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.circle)
                    }
                }
        } destination: { store in
            // Destination view based on the store's current state
            switch store.case {
            case let .exerciseLists(store):
                // ExerciseBluePrintsListView when the store's case is .exerciseLists
                ExerciseBluePrintsListView(store: store)
            case let .exerciseDetails(store):
                // ExerciseDetailView when the store's case is .exerciseDetails
                ExerciseDetailView(store: store)
            }
        }
    }
}


//#Preview {
//    @State var selectedDetent: PresentationDetent = .ExpandedSheetDetent
//    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
//
//    return WorkoutEditorBottomSheetView(viewModel: viewModel, selectedDetent: $selectedDetent)
//        .withPreviewEnvironment()
//}
