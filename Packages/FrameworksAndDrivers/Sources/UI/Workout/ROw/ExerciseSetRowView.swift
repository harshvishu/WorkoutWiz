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
    @State var lastSavedSet: ExerciseSet = .init(weight: 0, rep: 0)
    
    var body: some View {
            Button(action: {
                if let addedSet = editWorkoutViewModel.addSetToExercise(withID: exercise.id, weight: lastSavedSet.weight, type: lastSavedSet.type, unit: lastSavedSet.unit, failure: lastSavedSet.failure) {
                    withCustomSpring {
                        exercise.sets.append(addedSet)
                    }
                }
                
            }, label: {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    if exercise.sets.isEmpty  {
                        Label("No sets for this exercise.", systemImage: "lightbulb.circle.fill")
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                    } else {
                        let energy =  Measurement(value: exercise.estimatedCaloriesBurned(), unit: UnitEnergy.kilocalories)
                        Label(energy.formatted(.measurement(width: .abbreviated, usage: .workout)), systemImage: "flame")
                            .foregroundStyle(.purple)
                    }
                    
                    Spacer()
                    
                    Text("Add a set")
                        .foregroundStyle(.purple)
                        .fontWeight(.semibold)
                        .padding(2)
                }
                .font(.footnote)
                
            })
            .buttonStyle(.plain)
            .padding(EdgeInsets(top: 20, leading: 4, bottom: 2, trailing: 4))
            .background(
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 0.0,
                    bottomLeading: 8.0,
                    bottomTrailing: 8.0,
                    topTrailing: 0.0), style: .continuous)
                .fill(Color.purple.opacity(0.2))
            )
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            .offset(y: -16)
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
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                
                RowHeaderView(editWorkoutViewModel: editWorkoutViewModel, exercise: $exercise, isExpanded: $showExpandedSetView)
                //                .previewBorder(Color.green)
                
                // Sets
                VStack(alignment: .leading, spacing: 8) {
                    if showExpandedSetView {
                        // Show all exercise sets
                        ForEachWithIndex(exercise.sets, id: \.self) { index, set in
                            SetView(set: set, position: index)
                        }
                    } else {
                        // Show Summary View
                        Text("\(exercise.sets.count) sets. Max weight 7.5 Kg with Failure. Calories burned = \(exercise.estimatedCaloriesBurned(), specifier: "%0.02f") Cal")
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.leading, 8)
            }
            .padding(.listRowContentInset)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.tertiary, lineWidth: 0.5)
                    .fill(.background)
                    .onTapGesture {
                        // TODO: Open detailed view for editing
                    }
            }
            // Footer
            RowFooterView(editWorkoutViewModel: editWorkoutViewModel, exercise: $exercise)
                .zIndex(-1)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(.listRowInset)
    }
}


@Observable
fileprivate class ViewModel {
    var set: ExerciseSet
    init(set: ExerciseSet) {
        self.set = set
    }
}

struct SetView: View {
    private var position: Int
    
    @State fileprivate var viewModel: ViewModel
    @State private var interval: String = ""
    @State private var weight: String = ""
    
    init(set: ExerciseSet, position: Int) {
        self.viewModel = .init(set: set)
        self.position = position
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            
            HStack(alignment: .center, spacing: 4) {
                switch viewModel.set.type {
                case .duration:
                    
                    TextFieldDynamicWidth(title: "0.0", onEditingChanged: { _ in
                        
                    }, onCommit: {
                        guard let time = Double(interval)
                        else {return}
                        viewModel.set.update(type: .duration(time))
                    }, text: $interval)
                    .keyboardType(.numberPad)
                    .textContentType(.none)
                    .font(.title.bold())
                 
                    Text("min")
                        .font(.caption2)
                    
                case .rep(let count):
                    //                    TextField("0.0", text:  Binding(
                    //                        get: { formatTime(time, allowedUnits: [.minute], unitsStyle: .positional) },
                    //                        set: { viewModel.set.update(type: .duration((Double($0) ?? 0.0) * 60.0 ))}
                    //                    ))
                    
                    TextFieldDynamicWidth(title: "0", onEditingChanged: { _ in
                        
                    }, onCommit: {
                        guard let count = Int(interval)
                        else {return}
                        viewModel.set.update(type: .rep(count))
                    }, text: $interval)
                    .keyboardType(.numberPad)
                    .textContentType(.none)
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
                    Text("\(viewModel.set.weight, specifier: "%0.1f")")
                        .font(.title.bold())
                    Text("\(viewModel.set.unit.symbol)")
                        .font(.caption2)
                }
            }
            .frame(width: 120, alignment: .leading)
            
            if viewModel.set.failure {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.purple)
            }
        }
    }
}

#Preview {
    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    
    return List {
        ExerciseSetRowView(exercise: ExerciseRecord(template: ExerciseTemplate.mock_1, sets: [ExerciseSet(weight: 5.5, rep: 10,failure: true)]))
        ExerciseSetRowView(exercise: ExerciseRecord(template: ExerciseTemplate.mock_1, sets: [ExerciseSet(weight: 15.5, rep: 10,failure: true)]))
        ExerciseSetRowView(exercise: ExerciseRecord(template: ExerciseTemplate.mock_1, sets: [ExerciseSet(weight: 135, rep: 10,failure: true)]))
        
    }
    .listRowSpacing(.listRowVerticalSpacing)
    .withPreviewEnvironment()
    .environment(viewModel)
    
}
