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
    
    @State private var routerPath: RouterPath = .init()
    
    @Bindable var store: StoreOf<WorkoutEditorFeature>
    @Binding var selectedDetent: PresentationDetent
    
    init(store: StoreOf<WorkoutEditorFeature>, selectedDetent: Binding<PresentationDetent>) {
        self.store = store
        self._selectedDetent = selectedDetent
    }
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                
                WorkoutEditorView(store: store)
                    .opacity(selectedDetent.isCollapsed ? 0 : 1)
                    .environment(routerPath)
                
                Spacer()
                
            }
            .padding()
            .scrollIndicators(.hidden)
            .toolbar {
                
                ToolbarItemGroup(placement: .topBarLeading) {
                    WorkoutEditorSheetHeaderView(store: store)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {
                        selectedDetent.toggle()
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
            // TODO: remove this
            //            .onReceive(appState.signal) { signal in
            //                switch signal {
            //                case .openEditWorkoutSheet:
            //                    expand()
            //                case .closeWorkoutEditor:
            //                    collapse()
            //                default:
            //                    break
            //                }
            //            }
            
            /*
             .onChange(of: selectedDetent) { _, newValue in
             // Sheet collapsed and ListExerciseView is visible
             // Hide the header but do not close the sheet
             //                if routerPath.path.last == .listExercise && newValue == .InitialSheetDetent {
             //                    routerPath.path = []
             //                }
             }
             .onReceive(appState.signal) { signal in
             switch signal {
             case .openEditWorkoutSheet:
             expand()
             case .closeWorkoutEditor:
             collapse()
             case .openWorkout(let workout):
             if viewModel.isWorkoutInProgress {
             // TODO: What to do if one workout is already in progress
             // MAybe open in a new window/screen
             } else {
             viewModel.resume(workout: workout)
             expand()
             }
             default:
             break
             }
             }
             .task {
             viewModel.bind(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: SwiftDataWorkoutRepository(modelContext: modelContext.container.mainContext)))
             }
             */
            
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

fileprivate extension WorkoutEditorBottomSheetView {
    func collapse()  {
        withEaseOut {
            selectedDetent = .InitialSheetDetent
        }
    }
    
    func expand() {
        withEaseOut {
            selectedDetent = .ExpandedSheetDetent
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
