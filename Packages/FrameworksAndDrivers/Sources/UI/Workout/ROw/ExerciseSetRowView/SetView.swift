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
    
    var rep: String = ""
    var duration: String = ""
    var weight: String = ""
    
    init(set: ExerciseSet) {
        self.set = set
        
        switch set.type {
        case .duration(let time):
            self.duration = time == .zero ? "" : "\(time)"
        case .rep(let count):
            self.rep = count == 0 ? "" :  "\(count)"
        }
        
        self.weight = set.weight == .zero ? "" : "\(set.weight)"
    }
    
    func saveChanges() throws {
        switch set.type {
        case .duration:
            guard let duration = duration.double else {throw SetDataError.zeroDuration}
            set.update(type: .duration(duration))
        case .rep:
            guard let rep = rep.int else {throw SetDataError.zeroRep}
            set.update(type: .rep(rep))
        }
        guard let weight = weight.double else {throw SetDataError.zeroWeight}
        set.update(weight: weight)
    }
    
    enum SetDataError: Error {
        case zeroDuration
        case zeroRep
        case zeroWeight
    }
}


struct SetView: View {
    @Environment(WorkoutEditorViewModel.self) private var editWorkoutViewModel
        
    @State fileprivate var viewModel: ViewModel
    
    private var position: Int
   
    init(set: ExerciseSet, position: Int) {
        self.viewModel = .init(set: set)
        self.position = position
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            
            HStack(alignment: .center, spacing: 4) {
                switch viewModel.set.type {
                case .duration:
                    
                    TextFieldDynamicWidth(title: "0.0", keyboardType: .counter(onTimeChange, showPeriod: true), onCommit: {
                        do {
                            try viewModel.saveChanges()
                            editWorkoutViewModel.updateSet(viewModel.set)
                        } catch {
                            logger.error("\(error)")
                        }
                    }, text: $viewModel.rep)
                    .font(.title.bold())
                 
                    Text("min")
                        .font(.caption2)
                    
                case .rep:
                    TextFieldDynamicWidth(title: "0", keyboardType: .counter(onRepChange, showPeriod: false), onCommit: {
                        do {
                            try viewModel.saveChanges()
                            editWorkoutViewModel.updateSet(viewModel.set)
                        } catch {
                            logger.error("\(error)")
                        }
                    }, text: $viewModel.rep)
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
                    
                    TextFieldDynamicWidth(title: "0.0", keyboardType: .counter(onWeightChange, showPeriod: true), onCommit: {
                        do {
                            try viewModel.saveChanges()
                            editWorkoutViewModel.updateSet(viewModel.set)
                        } catch {
                            logger.error("\(error)")
                        }
                    }, text: $viewModel.weight)
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
        let updatedTime = (viewModel.weight.double ?? 0.0) + newTime
        guard updatedTime > 0.0 else {return}
        viewModel.duration = "\(updatedTime)"
    }
    
    private func onWeightChange(_ count: Int) {
        let newWeight = count > 0 ? 2.5 : -2.5
        let updatedWeight = (viewModel.weight.double ?? 0.0) + newWeight
        guard updatedWeight > 0.0 else {return}
        viewModel.weight = "\(updatedWeight)"
    }
    
    private func onRepChange(_ count: Int) {
        let newRep = count > 0 ? 1 : -1
        let updatedRep = (viewModel.rep.int ?? 0) + newRep
        guard updatedRep > 0 else {return}
        viewModel.rep = "\(updatedRep)"
    }
}

#Preview {
    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
    
    return SetView(set: ExerciseSet(exerciseID: UUID(), weight: 0.0, rep: 0,failure: true), position: 0)
    .withPreviewEnvironment()
    .environment(viewModel)
    .previewBorder()
}
