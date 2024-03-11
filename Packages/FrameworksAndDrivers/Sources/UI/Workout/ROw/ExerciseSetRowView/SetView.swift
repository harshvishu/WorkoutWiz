////
////  SetView.swift
////
////
////  Created by harsh vishwakarma on 20/01/24.
////
//
//import Domain
//import SwiftUI
//import DesignSystem
//import ApplicationServices
//import Persistence
//import OSLog
//
//
//@Observable
//fileprivate class ViewModel {
//    var set: ExerciseSetRecord
//    
//    var rep: String
//    var time: String
//    var weight: String
//    
//    init(set: ExerciseSetRecord) {
//        self.set = set
//        self.rep = set.rep == 0 ? "" : "\(set.rep)"
//        self.time = set.duration.isZero ? "" : "\(set.duration)"
//        self.weight = set.weight.isZero ? "" : "\(set.weight)"
//    }
//    
//    func onTimeChange(_ count: Int) {
//        let newTime = count > 0 ? 30.0 : -30.0
//        let updatedTime = (set.duration + newTime)
//        guard updatedTime >= 0.0 else {return}
//        duration = String(format: "%.2f", updatedTime)
//    }
//    
//    func onWeightChange(_ count: Int) {
//        let newWeight = count > 0 ? 2.5 : -2.5
//        let updatedWeight = (set.weight + newWeight).clamped(to: 0...999)
//        guard updatedWeight >= 0.0 else {return}
//        weight = String(format: "%.2f", updatedWeight)
//    }
//    
//    func onRepChange(_ count: Int) {
//        let newRep = count > 0 ? 1 : -1
//        let updatedRep = (set.rep + newRep).clamped(to: 0...9999)
//        rep = "\(updatedRep)"
//    }
//    
//    func onCommit(messageQueue: ConcreteMessageQueue<(ExerciseSetRecord, Int)>, position: Int) {
//        messageQueue.send((set, position))
//    }
//}
//
//struct SetView: View {
//    
//    enum Field: Hashable {
//        case durationField
//        case repField
//        case weightField
//    }
//    
//    @Environment(WorkoutEditorViewModel.self) private var editWorkoutViewModel
//    
//    @State fileprivate var viewModel: ViewModel
//    @FocusState private var focusedField: Field?
//    
//    private var messageQueue: ConcreteMessageQueue<(ExerciseSetRecord,Int)>
//    
//    init(set: ExerciseSetRecord, messageQueue: ConcreteMessageQueue<(ExerciseSetRecord,Int)>) {
//        self.viewModel = .init(set: set)
//        self.messageQueue = messageQueue
//    }
//    
//    var body: some View {
//        HStack(alignment: .center, spacing: 0) {
//            
//            Button(action: {
//                viewModel.set.failure.toggle()
//                commitChanges()
//            }, label: {
//                Image(systemName: "\(viewModel.set.position + 1).square")
//                    .foregroundStyle(.secondary)
//                    .frame(width: 25, height: 25)
//            })
//            .font(.title3)
//            .buttonStyle(.plain)
//            .padding(.trailing, 4)
//            
//            switch viewModel.set.type {
//            case .duration:
//                TextField("0.0", text: $viewModel.duration)
//                    .setKeyboard(.counter({ viewModel.onTimeChange($0) }, onNext: { focusedField = .weightField }, showPeriod: true))
//                    .onChange(of: viewModel.duration) { oldValue, newValue in
//                        if newValue.double == nil && newValue.isNotEmpty {
//                            viewModel.duration = oldValue
//                        }
//                        viewModel.set.duration = viewModel.duration.double ?? 0.0
//                    }
//                    .onSubmitCustomKeyboard(action: commitChanges)
//                    .focused($focusedField, equals: .durationField)
//                    .font(.title.bold())
//                
//            case .rep:
//                TextField("0", text: $viewModel.rep)
//                    .setKeyboard(.counter({ viewModel.onRepChange($0) }, onNext: { focusedField = .weightField }, showPeriod: false))
//                    .onChange(of: viewModel.rep) { oldValue, newValue in
//                        if newValue.int == nil && newValue.isNotEmpty {
//                            viewModel.rep = oldValue
//                        }
//                        viewModel.set.rep = viewModel.rep.int ?? 0
//                    }
//                    .onSubmitCustomKeyboard(action: commitChanges)
//                    .focused($focusedField, equals: .repField)
//                    .font(.title.bold())
//            }
//            
//            Text("x")
//                .font(.caption2)
//                .foregroundStyle(.secondary)
//                .padding(.horizontal, 8)
//            
//            TextField("0.0", text: $viewModel.weight)
//                .setKeyboard(.counter({ viewModel.onWeightChange($0) }, onNext: nil, showPeriod: true))
//                .onChange(of: viewModel.weight) { oldValue, newValue in
//                    if newValue.double == nil && newValue.isNotEmpty {
//                        viewModel.weight = oldValue
//                    }
//                    viewModel.set.weight = viewModel.weight.double ?? 0.0
//                }
//                .onSubmitCustomKeyboard(action: commitChanges)
//                .focused($focusedField, equals: .weightField)
//                .font(.title.bold())
//            
//            Image(systemName: "f.circle.fill")
//                .foregroundStyle(.purple)
//                .opacity(viewModel.set.failure ? 1 : 0)
//                .frame(width: 32)
//            
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//    
//    private func commitChanges() {
//        viewModel.onCommit(messageQueue: messageQueue, position: viewModel.set.position)
//        focusedField = nil
//    }
//}
//
//#Preview {
//    @State var viewModel = WorkoutEditorViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: MockWorkoutRepository()))
//    @State var messageQueue: ConcreteMessageQueue<(ExerciseSetRecord,Int)> = .init()
//    
//    return SetView(set: ExerciseSetRecord(workoutDocumentID: "1", exerciseDocumentID: "1_2", weight: 135, type: .duration, duration: 70.50, rep: 10,failure: true, calories: 2.5, position: 0), messageQueue: messageQueue)
//        .withPreviewEnvironment()
//        .environment(viewModel)
//        .previewBorder()
//}
