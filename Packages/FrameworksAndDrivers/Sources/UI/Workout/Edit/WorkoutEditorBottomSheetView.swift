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
    
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var store: StoreOf<WorkoutEditorFeature>
    @Binding var selectedDetent: PresentationDetent
    
    init(store: StoreOf<WorkoutEditorFeature>, selectedDetent: Binding<PresentationDetent>) {
        self.store = store
        self._selectedDetent = selectedDetent
    }
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            WorkoutEditorView(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(selectedDetent.isCollapsed ? 0 : 1)
                .scrollIndicators(.hidden)
                .toolbar {
                    
                    ToolbarItemGroup(placement: .topBarLeading) {
                        WorkoutEditorSheetHeaderView(store: store, selectedDetent: $selectedDetent)
                    }
                    
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(action: {
                            hideKeyboard()
                            store.send(.delegate(.toggleBottomSheet))
                        }, label: {
                            if  store.isWorkoutInProgress {
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
            switch store.case {
            case let .exerciseLists(store):
                ExerciseBluePrintsListView(store: store)
                    .opacity(selectedDetent.isCollapsed ? 0 : 1)
            case .exerciseDetails:
                Text("TODO: Pending Exercise Details")
            }
        }
        
    }
}

//fileprivate extension WorkoutEditorBottomSheetView {
//    func collapse()  {
//        withEaseOut {
//            selectedDetent = .InitialSheetDetent
//        }
//    }
//
//    func expand() {
//        withEaseOut {
//            selectedDetent = .ExpandedSheetDetent
//        }
//    }
//}

//#Preview {
//    @State var selectedDetent: PresentationDetent = .ExpandedSheetDetent
//    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
//
//    return WorkoutEditorBottomSheetView(viewModel: viewModel, selectedDetent: $selectedDetent)
//        .withPreviewEnvironment()
//}
