//
//  RepInputView.swift
//
//
//  Created by harsh vishwakarma on 16/02/24.
//

import SwiftUI
import Domain
import ApplicationServices
import Persistence
import DesignSystem
import ComposableArchitecture

public enum FocusField: Hashable {
    case time
    case rep
    case weight
}

@Reducer
public struct RepInput {
    
    @ObservableState
    public struct State: Equatable {
        var exercise: Exercise
        var rep: Rep?
        
        var repCount: Int = 0
        var repTime: TimeInterval = 0
        var weight: Double = 0
        var repCountUnit: RepCountUnit = .rep
        var weightUnit: WeightUnit = .kg
        var repType: RepType = .dropset
        var val: String = ""
        var isRepCountFocused: Bool = true
        var focusedField: FocusField?
        var repInputMode: RepInputMode = .repCount
        
        init(exercise: Exercise) {
            self.exercise = exercise
            // TODO: Use save manager to get last saved info
            self.repCount = 0
            self.repTime = 0
            self.weight = 0
            self.repCountUnit = exercise.preferredRepCountUnit()
            self.weightUnit = .kg
            self.repType = .none
            
            switch exercise.preferredRepCountUnit() {
            case .rep:
                val = "0"
                focusedField = .rep
            case .time:
                val = "0:0"
                focusedField = .time
            }
        }
        
        init(exercise: Exercise, rep: Rep) {
            self.exercise = exercise
            self.rep = rep
            
            self.repCount = rep.count
            self.repTime = rep.time
            self.weight = rep.weight
            self.repCountUnit = rep.countUnit
            self.weightUnit = rep.weightUnit
            self.repType = rep.repType
            
            switch rep.countUnit {
            case .rep:
                val = "\(rep.count)"
                focusedField = .rep
            case .time:
                val = rep.time.formattedElapsedTime()
                focusedField = .time
            }
        }
    }
    
    public enum Action {
        case delegate(Delegate)
        public enum Delegate {
            case close
        }
        
        case repTypeChanged(RepType)
        case repInputModeChanged(RepInputMode)
        case repTimeChanged(TimeInterval)
        case valChanged(String)
        case removeLastVal
        case focusedFieldChanged(FocusField?)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none
            case let .focusedFieldChanged(focusedField):
                state.focusedField = focusedField
                return .none
            case let .repTypeChanged(repType):
                state.repType = repType
                return .none
            case let .repInputModeChanged(repInputMode):
                state.repInputMode = repInputMode
                return .none
            case let .valChanged(val):
                state.val = val
                return .none
            case .removeLastVal:
                state.val.removeLast()
                return .none
            case let .repTimeChanged(repTime):
                state.repTime = repTime
                return .none
            }
        }
        .onChange(of: \.repCountUnit, { _, newValue in
            Reduce { state, _ in
                switch newValue {
                case .rep:
                    state.repInputMode = .repCount
                    if state.focusedField != .weight {
                        state.focusedField = .rep
                    }
                case .time:
                    state.repInputMode = .timeCount
                    if state.focusedField != .weight {
                        state.focusedField = .time
                    }
                }
                return .none
            }
        })
        .onChange(of: \.val) { _, newValue in
            Reduce { state, _ in
                switch state.repCountUnit {
                case .rep:
                    state.repCount = newValue.int ?? 0
                case .time:
                    let time = TimeInterval(newValue.double ?? 0.0)
                    state.repTime = time
                }
                return .none
            }
          
        }
    }
}

@MainActor
struct RepInputView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var fitnessTrackingUseCase: FitnessTrackingIOPort = FitnessTrackingUseCase()
    
    @Bindable var store: StoreOf<RepInput>
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center, spacing: 4) {
                
                Button(action: {
                    // TODO: change rep input mode for set
                    
                    // Also change if exercise does not have any rep
//                    withCustomSpring {
//                        let newRepInputMode: RepCountUnit = (store.repInputMode == .repCount) ? .time : .rep
//                        if store.exercise.reps.isEmpty {
//                            store.exercise.repCountUnit = newRepInputMode
//                            store.repCountUnit = newRepInputMode
//                        }
//                    }
                    
                }, label: {
                    Image(systemName: store.repCountUnit == .rep ? "123.rectangle.fill" : "timer")
                        .symbolEffect(.bounce, value: store.repCountUnit)
                        .contentTransition(.symbolEffect(.replace.byLayer))
                })
                .buttonStyle(.plain)
                .disabled(store.exercise.reps.count > 0)
                
                VStack(alignment: .center) {
                    switch store.repCountUnit {
                    case .time:
                        Text(store.repTime.formattedElapsedTime(formatter: minutesSecondsFormatter))
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(store.focusedField == .time ? appAccentColor : Color.primary)
                            .bipAnimation(trigger: store.focusedField == .rep)
                        
                    case .rep:
                        Text(store.repCount, format: .number)
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(store.focusedField == .rep ? appAccentColor : Color.primary)
                            .bipAnimation(trigger: store.focusedField == .rep)
                    }
                    
                    Text("\(store.repCountUnit.description)")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(alignment: .center) {
                    Text(store.weight, format: .number.precision(.fractionLength(2)))
                        .font(.title.bold())
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(store.focusedField == .weight ? appAccentColor : Color.primary)
                        .bipAnimation(trigger: store.focusedField == .weight)
                    
                    Text("\(store.weightUnit.sfSymbol)")
                        .font(.caption2)
                }
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
            .frame(maxWidth: .infinity)
            
            Divider()
            
            Picker(selection: $store.repType.sending(\.repTypeChanged), label: Text("Mark set as")) {
                ForEach(RepType.allCases, id:\.self) {
                    Text($0.description)
                        .tag($0.rawValue)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .pickerStyle(.segmented)
            
            Divider()
            
            RepInputKeyboard(value: $store.val.sending(\.valChanged), mode: $store.repInputMode.sending(\.repInputModeChanged), keyPressHandler:  { key in
                if case .submit = key {
                    
                    let calories = fitnessTrackingUseCase.trackCaloriesBurned(
                        metValue: store.exercise.template?.category.met() ?? 0.0,
                        weight: store.weight,
                        repCountUnit: store.repCountUnit,
                        duration: store.repTime,
                        rep: store.repCount
                    )
                    
                    if let rep = store.rep {
                        rep.weight = store.weight
                        rep.count = store.repCount
                        rep.time = store.repTime
                        rep.weightUnit = store.weightUnit
                        rep.repType = store.repType
                        rep.countUnit = store.repCountUnit
                        rep.calories = calories
                    } else {
                        let position = store.exercise.reps.count
                        
                        let rep = Rep(
                            weight: store.weight,
                            countUnit: store.repCountUnit,
                            time: store.repTime,
                            count: store.repCount,
                            weightUnit: store.weightUnit,
                            calories: calories,
                            position: position,
                            repType: store.repType
                        )
                        store.exercise.reps.append(rep)
                        rep.exercise = store.exercise
                    }
                    
                    // Update the calories whenever a rep is added/ deleted or modified
                    // TODO: Delete REP is pending
                    store.exercise.calories = Exercise.estimatedCaloriesBurned(reps: store.exercise.reps)
                    
                    if let workout = store.exercise.workout {
                        let totalCaloriesBurnedForExercise = Workout.estimatedCaloriesBurned(exercises: workout.exercises)
                        workout.calories = totalCaloriesBurnedForExercise
                    }
                    
                    store.send(.delegate(.close), animation: .default)
                } else if case CustomKey.digit(let num) = key {
                    let finalVal = store.val.appending("\(num)")
                    if finalVal.int != nil && finalVal.count < 5 {    // is a valid Integer
                        store.send(.valChanged(finalVal))
                    }
                } else if case CustomKey.delete = key {
                    if store.val.count > 0 {  // No more delete
                        store.send(.removeLastVal)
                    }
                } else if case CustomKey.next = key {
                    if store.focusedField == .weight {
                        store.send(.focusedFieldChanged(store.repCountUnit == .rep ? .rep : .time), animation: .default)
                    } else {
                        store.send(.focusedFieldChanged(.weight), animation: .default)
                    }
                }
            }, timeChangeHandler: { time in
                store.send(.repTimeChanged(time))
            })
        }
    }
}

//#Preview {
//    return VStack {
//        Spacer()
//
//        RepInputView(exercise: Exercise(), onClose: {})
//            .withPreviewEnvironment()
//            .previewBorder()
//    }
//}
