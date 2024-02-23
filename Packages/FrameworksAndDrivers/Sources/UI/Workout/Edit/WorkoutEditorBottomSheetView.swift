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

@MainActor
public struct WorkoutEditorBottomSheetView: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: WorkoutEditorBottomSheetView.self))
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    @State private var viewModel: WorkoutEditorViewModel
    @State private var routerPath: RouterPath = .init()
    
    @Binding var selectedDetent: PresentationDetent
        
    public init(selectedDetent: Binding<PresentationDetent>) {
        self._viewModel = .init(initialValue: WorkoutEditorViewModel())
        self._selectedDetent = selectedDetent
    }
    
    public init(viewModel: WorkoutEditorViewModel, selectedDetent: Binding<PresentationDetent>) {
        self._viewModel = .init(initialValue: viewModel)
        self._selectedDetent = selectedDetent
    }
    
    public var body: some View {
        NavigationStack(path: $routerPath.path) {
            VStack {
                
                WorkoutEditorView()
                    .opacity(selectedDetent.isCollapsed ? 0 : 1)
                    .environment(viewModel)
                    .environment(routerPath)
                
                Spacer()
                
//                // Collapsed View
//                if selectedDetent.isCollapsed {
//                    Spacer()
//                } else {
//                    
//                    // Expanded View
//                    WorkoutEditorView()
//                        .environment(viewModel)
//                        .environment(routerPath)
//                    
//                }
            }
            .padding()
            .scrollIndicators(.hidden)
            .toolbar {
                
                ToolbarItemGroup(placement: .topBarLeading) {
                    WorkoutEditorSheetHeaderView()
                        .environment(viewModel)
                        .environment(routerPath)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {
                        selectedDetent.toggle()
                    }, label: {
                        if viewModel.isWorkoutActive {
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
            .onReceive(appState.signal) { signal in
                switch signal {
                case .openEditWorkoutSheet:
                    expand()
                case .closeWorkoutEditor:
                    collapse()
                default:
                    break
                }
            }
          
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

#Preview {
    @State var selectedDetent: PresentationDetent = .ExpandedSheetDetent
    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    
    return WorkoutEditorBottomSheetView(viewModel: viewModel, selectedDetent: $selectedDetent)
        .withPreviewEnvironment()
}
