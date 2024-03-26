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
        
        var weightText: String = ""
        var repCountText: String = ""
        var repTimeText: String = ""
        
        var repCountUnit: RepCountUnit = .rep
        var weightUnit: WeightUnit = .kg
        var repType: RepType = .dropset
        
        var isRepCountFocused: Bool = true
        var focusedField: FocusField?
        var isRepSaved = false
        
        init(exercise: Exercise) {
            self.exercise = exercise
            
            // TODO: Use save manager to get last saved info
            self.repCountUnit = exercise.preferredRepCountUnit()
            self.weightUnit = .kg
            self.repType = .none
            
            switch exercise.preferredRepCountUnit()  {
            case .rep:
                focusedField = .rep
            case .time:
                focusedField = .time
            }
        }
        
        init(exercise: Exercise, rep: Rep) {
            self.exercise = exercise
            self.rep = rep
            
            self.repCountUnit = rep.countUnit
            self.weightUnit = rep.weightUnit
            self.repType = rep.repType
            
            switch rep.countUnit {
            case .rep:
                focusedField = .rep
            case .time:
                focusedField = .time
            }
            
            weightText = rep.weight.isZero ? "" : String(format: hasFraction(rep.weight) ? "%.2f" : "%.0f", rep.weight)
            repTimeText = rep.time.formattedElapsedTime(formatter: minutesSecondsFormatter)
            repCountText = String(format: "%d", rep.count)
            isRepSaved = true
        }
    }
    
    public enum Action {
        case changeRepCountUnit(RepCountUnit)
        case deleteButtonTapped
        
        case delegate(Delegate)
        public enum Delegate {
            case close
        }
        
        case repTypeChanged(RepType)
        case repTimeChanged(TimeInterval)
        
        case focusedFieldChanged(FocusField?)
        
        case keypadInputReceived(Int)
        case keypadDeleteButtonPressed
        case keypadPeriodButtonPressed
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .changeRepCountUnit(repCountUnit):
                guard state.exercise.reps.isEmpty else {return .none}
                state.repCountUnit = repCountUnit
                state.exercise.repCountUnit = repCountUnit
                let focusField: FocusField = repCountUnit == .rep ? .rep : .time
                return .send(.focusedFieldChanged(focusField))
                
            case .deleteButtonTapped:
                if let id = state.rep?.id, state.isRepSaved {
                    state.exercise.reps.removeAll { $0.id == id }
                }
                return .send(.delegate(.close))
                
            case let .keypadInputReceived(num):
                switch state.focusedField {
                case .some(.rep):
                    let repCountText = "\(state.repCountText)\(num)"
                    if repCountText.count > 4 {
                        return .none
                    }
                    
                    if let repCount = repCountText.int {
                        state.repCountText = (repCount == 0) ? "" : "\(repCount)"
                    }
                case .some(.weight):
                    let weightText = "\(state.weightText)\(num)"
                    if weightText.contains(".") {
                        let components = weightText.split(separator: ".")
                        if let fraction = components.last, fraction.count > 2 {
                            return .none
                        }
                    } else if weightText.count > 4 {
                        return .none
                    }
                    
                    if let weight = weightText.double {
                        state.weightText = weight.isZero ? "" : weightText
                    }
                    
                case .none, .some(.time):
                    break
                }
                return .none
                
            case .keypadPeriodButtonPressed:
                if state.focusedField == .weight && !state.weightText.contains(".") {
                    state.weightText.append(".")
                }
                return .none
                
            case .keypadDeleteButtonPressed:
                switch state.focusedField {
                case .some(.rep):
                    if state.repCountText.isNotEmpty {
                        state.repCountText.removeLast()
                    }
                case .some(.weight):
                    if state.weightText.isNotEmpty {
                        _ = state.weightText.removeLast()
                    }
                case .none, .some(.time):
                    break
                }
                return .none
                
            case let .focusedFieldChanged(focusedField):
                state.focusedField = focusedField
                return .none
                
            case let .repTypeChanged(repType):
                state.repType = repType
                return .none
                
            case let .repTimeChanged(repTime):
                state.repTimeText = repTime.formattedElapsedTime(formatter: minutesSecondsFormatter)
                return .none
                
            case .delegate:
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
    @State var isDeleteButtonEnabled = false
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center, spacing: 4) {
                
                // MARK: Rep Count Type toggle
                Button(action: {
                    let newRepInputMode: RepCountUnit = (store.repCountUnit == .rep) ? .time : .rep
                    store.send(.changeRepCountUnit(newRepInputMode), animation: .customSpring())
                    // Also change if exercise does not have any rep
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
                        // MARK: Time
                        Text(store.repTimeText.isEmpty ? "0:0" : store.repTimeText)
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(store.focusedField == .time ? appAccentColor : Color.primary)
                            .bipAnimation(trigger: store.focusedField == .rep)
                            .contentTransition(.numericText())
                        
                    case .rep:
                        // MARK: Rep Count
                        Text(store.repCountText.isEmpty ? "0" : store.repCountText)
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(store.focusedField == .rep ? appAccentColor : Color.primary)
                            .bipAnimation(trigger: store.focusedField == .rep)
                            .contentTransition(.numericText())
                    }
                    
                    Text("\(store.repCountUnit.description)")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                // MARK: Weight
                VStack(alignment: .center) {
                    Text(store.weightText.isEmpty ? "0" : store.weightText)
                        .font(.title.bold())
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(store.focusedField == .weight ? appAccentColor : Color.primary)
                        .bipAnimation(trigger: store.focusedField == .weight)
                        .contentTransition(.numericText())
                    
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
            
            
            RepInputKeyboard(mode: getRepInputMode(), keyPressHandler:  { key in
                if case .submit = key {
                    
                    let weight = store.weightText.double ?? 0.0
                    let repCount = store.repCountText.int ?? 0
                    let repTime = timeInterval(from: store.repTimeText, formatter: minutesSecondsFormatter) ?? 0.0
                    
                    let calories = fitnessTrackingUseCase.trackCaloriesBurned(
                        metValue: store.exercise.template?.category.met() ?? 0.0,
                        weight: weight,
                        repCountUnit: store.repCountUnit,
                        duration: repTime,
                        rep: repCount
                    )
                    
                    if let rep = store.rep {
                        rep.weight = weight
                        rep.count = repCount
                        rep.time = repTime
                        rep.weightUnit = store.weightUnit
                        rep.repType = store.repType
                        rep.countUnit = store.repCountUnit
                        rep.calories = calories
                    } else {
                        let position = store.exercise.reps.count
                        
                        let rep = Rep(
                            weight: weight,
                            countUnit: store.repCountUnit,
                            time: repTime,
                            count: repCount,
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
                    store.send(.keypadInputReceived(num), animation: .default)
                } else if case CustomKey.delete = key {
                    store.send(.keypadDeleteButtonPressed, animation: .default)
                } else if case CustomKey.next = key {
                    if store.focusedField == .weight {
                        store.send(.focusedFieldChanged(store.repCountUnit == .rep ? .rep : .time), animation: .default)
                    } else {
                        store.send(.focusedFieldChanged(.weight), animation: .default)
                    }
                } else if case CustomKey.period = key {
                    if store.focusedField == .weight {
                        store.send(.keypadPeriodButtonPressed, animation: .default)
                    }
                }
            }, timeChangeHandler: { time in
                store.send(.repTimeChanged(time))
            })
            
            if store.isRepSaved {
                Button(role: .destructive, action: {
                    store.send(.deleteButtonTapped, animation: .default)
                }, label: {
                    Label("Delete", systemImage: "trash.fill")
                        .padding(.buttonContentInsets)
                })
                .buttonBorderShape(.capsule)
                .overlay(
                    Capsule().stroke(Color.accentColor)
                )
            }
        }
    }
    
    private func getRepInputMode() -> RepInputMode {
        if store.focusedField == .weight {
            return .weight
        } else if store.repCountUnit == .rep {
            return .repCount
        } else {
            return .timeCount
        }
    }
}
