//
//  ExerciseSetRowView.swift
//
//
//  Created by harsh vishwakarma on 13/12/23.
//

import Domain
import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence

// Footer View
fileprivate struct RowFooterView: View {
//    @Environment(EditWorkoutViewModel.self) private var editWorkoutViewModel
    @Environment(SaveDataManager.self) private var saveDataManager
        
    var editWorkoutViewModel: WorkoutEditorViewModel
    
    @Binding var exercise: ExerciseRecord
    @State var lastSavedSet: ExerciseSet = .init(weight: 5, duration: 45)
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 4) {
            if exercise.sets.isEmpty {
                Label("No sets for this exercise.", systemImage: "lightbulb.circle.fill")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                    .transition(.opacity)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    exercise.sets.append(lastSavedSet)
                    editWorkoutViewModel.addSetToExercise(withID: exercise.id, weight: lastSavedSet.weight, type: lastSavedSet.type, unit: lastSavedSet.unit, failure: lastSavedSet.failure)
                }
            }, label: {
                Text("Add a set")
                    .font(.footnote)
                    .padding(2)
            })
            .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.purple, style: StrokeStyle(lineWidth: 0.5, dash: [3], dashPhase: 0.5))
            }
            .foregroundStyle(.purple)
            .buttonStyle(.plain)
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        .task {
//            await lastSavedSet = saveDataManager.readSaveDataFor(exerciseName: exercise.template.name)?.sets.first ?? .init(weight: 5.0, rep: 10)
        }
    }
}

// Header View
fileprivate struct RowHeaderView: View {
//    @Environment(EditWorkoutViewModel.self) private var editWorkoutViewModel
    
    var editWorkoutViewModel: WorkoutEditorViewModel
    
    @Binding var exercise: ExerciseRecord
    @Binding var isExpanded: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            }
            .foregroundStyle(.tertiary)
            .symbolVariant(.circle)
            .contentTransition(.symbolEffect(.replace.downUp.byLayer))
            .buttonStyle(.plain)
            
            Text(exercise.template.name)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: {
                Swift.print("Info Button tapped")
            }, label: {
                Image(systemName: "info.circle.fill")
            })
            .buttonStyle(.plain)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: 24)
    }
}

public struct ExerciseSetRowView: View {
    @Environment(WorkoutEditorViewModel.self) private var editWorkoutViewModel
    
    @State private var exercise: ExerciseRecord
    @State private var showExpandedSetView = true
    
    init(exercise: ExerciseRecord) {
        self._exercise = .init(initialValue: exercise)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            
            RowHeaderView(editWorkoutViewModel: editWorkoutViewModel, exercise: $exercise, isExpanded: $showExpandedSetView)
                .previewBorder(Color.green)
            
            // Sets
            VStack(alignment: .leading, spacing: 8) {
                if showExpandedSetView {
                    // Show all exercise sets
                    ForEach(exercise.sets, id: \.self) { set in
                        HStack(alignment: .center, spacing: 0) {
                            
                            HStack(alignment: .center, spacing: 4) {
                                switch set.type {
                                case .duration(let time):
                                    
                                    Text(formatTime(time, allowedUnits: [.second], unitsStyle: .positional))
                                        .font(.title.bold())
                                    
                                    Image(systemName: "timer")
                                        .font(.caption2)
                                    
                                case .rep(let count):
                                    Text("\(count)")
                                        .font(.title.bold())
                                    
                                    Text("reps")
                                        .font(.caption2)
                                }
                            }
                            
                            
                            Spacer()
                            HStack(alignment: .center, spacing: 20) {
                                Text("x")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                
                                                            
                                HStack(alignment: .center, spacing: 4) {
                                    Text("\(set.weight, specifier: "%0.1f")")
                                        .font(.title.bold())
                                    Text("\(set.unit.symbol)")
                                        .font(.caption2)
                                }
                                
//                                Spacer()
                            }
                            .frame(width: 120, alignment: .leading)
                            
                            if set.failure {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(.purple)
                            }
                        }
                    }
                } else {
                    // Show Summary View
                    Text("\(exercise.sets.count) sets. Max weight 7.5 Kg with Failure. Calories burned = \(exercise.estimatedCaloriesBurned(), specifier: "%0.02f") Cal")
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.leading, 8)
            .previewBorder(Color.orange)
            
            // Footer
            RowFooterView(editWorkoutViewModel: editWorkoutViewModel, exercise: $exercise)
                .previewBorder(Color.blue)
        }
        .padding(.listRowContentInset)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.tertiary, lineWidth: 0.5)
                .onTapGesture {
                    // TODO: Open detailed view for editing
                }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(.listRowInset)
    }
}

#Preview {
    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    @State var saveDataManager = SaveDataManager(saveDataUseCase: SaveDataUseCase(saveDataRepository: UserDefaultsSaveDataRepository()))
    @State var globalMessageQueue: ConcreteMessageQueue<ApplicationMessage> = .init()
    
    return VStack {
        List {
            ExerciseSetRowView(exercise: ExerciseRecord(template: ExerciseTemplate.mock_1, sets: [ExerciseSet(weight: 5.5, rep: 10,failure: true)]))
            ExerciseSetRowView(exercise: ExerciseRecord(template: ExerciseTemplate.mock_1, sets: [ExerciseSet(weight: 15.5, rep: 10,failure: true)]))
            ExerciseSetRowView(exercise: ExerciseRecord(template: ExerciseTemplate.mock_1, sets: [ExerciseSet(weight: 135, rep: 10,failure: true)]))
        }
        .listRowSpacing(.listRowVerticalSpacing)
    }
    .environment(viewModel)
    .environment(saveDataManager)
    .environment(globalMessageQueue)
    .withPreviewModelContainer()
    
}
