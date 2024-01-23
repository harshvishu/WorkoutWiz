//
//  SetView.swift
//
//
//  Created by harsh vishwakarma on 20/01/24.
//

import Domain
import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(#file)")

@Observable
fileprivate class ViewModel {
    var set: ExerciseSet
    
    var type: SetType
    var timeDuration: TimeInterval
    var repCount: Int
    
    var rep: String = ""
    var duration: String = ""
    var weight: String = ""
    
    init(set: ExerciseSet) {
        self.set = set
        self.timeDuration = set.duration
        self.repCount = set.rep
        
        self.type = set.type
        switch set.type {
        case .duration:
            self.duration = timeDuration == .zero ? "" : "\(timeDuration)"
        case .rep:
            self.rep = repCount == 0 ? "" :  "\(repCount)"
        }
        
        self.weight = set.weight == .zero ? "" : "\(set.weight)"
    }
    
    func saveChanges() throws {
        switch set.type {
        case .duration:
            guard let duration = duration.double else {throw SetDataError.zeroDuration}
            self.timeDuration = duration
        case .rep:
            guard let rep = rep.int else {throw SetDataError.zeroRep}
            self.repCount = rep
        }
        guard let weight = weight.double else {throw SetDataError.zeroWeight}
        
        set.update(weight: weight, type: type, duration: timeDuration, rep: repCount)
    }
    
    enum SetDataError: Error {
        case zeroDuration
        case zeroRep
        case zeroWeight
    }
}


struct SetView: View {
    
    enum Field: Hashable {
        case durationField
        case repField
        case weightField
    }
    
    @Environment(WorkoutEditorViewModel.self) private var editWorkoutViewModel
    
    @State fileprivate var viewModel: ViewModel
    @FocusState private var focusedField: Field?
    
    private var position: Int
    private var messageQueue: ConcreteMessageQueue<(ExerciseSet,Int)>
    
    init(set: ExerciseSet, position: Int, messageQueue: ConcreteMessageQueue<(ExerciseSet,Int)>) {
        self.viewModel = .init(set: set)
        self.position = position
        self.messageQueue = messageQueue
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            
            HStack(alignment: .center, spacing: 4) {
                switch viewModel.set.type {
                case .duration:
                    
//                    TextFieldDynamicWidth(title: "0.0", keyboardType: .counter(onTimeChange, onNext: {
//                        focusedField = .weightField
//                    }, showPeriod: true), onCommit: onCommit, text: $viewModel.duration)
//                    .focused($focusedField, equals: Field.durationField)
//                    .font(.title.bold())
                    
                    TextField("0.0", text: $viewModel.duration)
                        .setKeyboard(.counter(onTimeChange(_:), onNext: {
                            focusedField = .weightField
                        }, showPeriod: true))
                        .onSubmitCustomKeyboard(action: onCommit)
                        .focused($focusedField, equals: Field.durationField)
                        .font(.title.bold())
                    
                    Text("min")
                        .font(.caption2)
                    
                case .rep:
//                    TextFieldDynamicWidth(title: "0", keyboardType: .counter(onRepChange, onNext: {
//                        focusedField = .weightField
//                    }, showPeriod: false), onCommit: onCommit, text: $viewModel.rep)
//                    .focused($focusedField, equals: Field.repField)
//                    .font(.title.bold())
                    
                    TextField("0.0", text: $viewModel.rep)
                        .setKeyboard(.counter(onRepChange(_:), onNext: {
                            focusedField = .weightField
                        }, showPeriod: false))
                        .onSubmitCustomKeyboard(action: onCommit)
                        .focused($focusedField, equals: Field.repField)
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
                    
//                    TextFieldDynamicWidth(title: "0.0", keyboardType: .counter(onWeightChange, showPeriod: true), onCommit: onCommit, text: $viewModel.weight)
//                    .focused($focusedField, equals: Field.weightField)
//                    .font(.title.bold())
                    
                    TextField("0.0", text: $viewModel.weight)
                        .setKeyboard(.counter(onWeightChange(_:), onNext: nil, showPeriod: false))
                        .onSubmitCustomKeyboard(action: onCommit)
                        .focused($focusedField, equals: Field.weightField)
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
    
    
    private func onTimeChange(_ count: Int) {
        let newTime = count > 0 ? 30.0 : 30.0
        let updatedTime = ((viewModel.weight.double ?? 0.0) + newTime)
        guard updatedTime > 0.0 else {return}
        viewModel.duration = "\(updatedTime)"
    }
    
    private func onWeightChange(_ count: Int) {
        let newWeight = count > 0 ? 2.5 : -2.5
        let updatedWeight = ((viewModel.weight.double ?? 0.0) + newWeight).clamped(to: 0...999)
        guard updatedWeight > 0.0 else {return}
        viewModel.weight = "\(updatedWeight)"
    }
    
    private func onRepChange(_ count: Int) {
        let newRep = count > 0 ? 1 : -1
        let updatedRep = ((viewModel.rep.int ?? 0) + newRep).clamped(to: 0...999)
        viewModel.rep = "\(updatedRep)"
    }
    
    private func onCommit() {
        do {
            try viewModel.saveChanges()
            messageQueue.send((viewModel.set, position))
        } catch {
            logger.error("\(error)")
        }
        focusedField = nil
    }
}

#Preview {
    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    @State var messageQueue: ConcreteMessageQueue<(ExerciseSet,Int)> = .init()

    
    return SetView(set: ExerciseSet(exerciseID: UUID(), weight: 10.0, type: .rep, duration: 10.0, rep: 10,failure: true, calories: 2.5), position: 0, messageQueue: messageQueue)
        .withPreviewEnvironment()
        .environment(viewModel)
        .previewBorder()
}
