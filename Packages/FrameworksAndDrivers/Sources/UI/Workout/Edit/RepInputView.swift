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

// TODO: The view need performance improvements
public enum FocusField: Hashable {
    case time
    case rep
    case weight
}

/**
 A reducer struct `RepInput` that manages the state and actions related to inputting rep details.
 */
@Reducer
public struct RepInput {
    
    /**
     An inner reducer enum `Destination` for manging alerts and presentations.
     */
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)
        
        @CasePathable
        public enum Alert {
            case confirmDelete
            case cancelDelete
        }
    }
    
    /**
     A state struct `State` for managing rep input related state variables.
     */
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        
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
        
        /**
         Initializes the state with the provided exercise.
         - Parameters:
            - exercise: The exercise associated with the rep input.
         */
        init(exercise: Exercise) {
            self.exercise = exercise
            
            // TODO: Use save manager to get last saved info
            self.repCountUnit = exercise.preferredRepCountUnit
            self.weightUnit = .kg
            self.repType = .standard
            
            switch repCountUnit  {
            case .rep:
                focusedField = .rep
            case .time:
                focusedField = .time
            }
        }
        
        /**
         Initializes the state with the provided exercise and rep.
         - Parameters:
            - exercise: The exercise associated with the rep input.
            - rep: The rep details to initialize the state.
         */
        init(exercise: Exercise, rep: Rep) {
            self.exercise = exercise
            self.rep = rep
            
            self.repCountUnit = rep.countUnit
            self.weightUnit = rep.weightUnit
            self.repType = rep.repType
            
            switch repCountUnit {
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
    
    /**
     An enum `Action` defining the actions that can be performed in the rep input.
     */
    public enum Action {
        case changeRepCountUnit(RepCountUnit)
        /// Deletes the workout. Use with caution as this action is irreversible.
        /// - Warning: This action is irreversible. Make sure you want to permanently delete the Rep.
        @available(*, message: "Use with caution as this action is irreversible. Do not call directly. Use `deleteButtonTapped` instead")
        case deleteRep
        case deleteButtonTapped
        
        case destination(PresentationAction<Destination.Action>)
        
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
    
    /**
     The body of the reducer, defining how actions modify the state.
     */
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .changeRepCountUnit(repCountUnit):
                guard state.exercise.reps.isEmpty else {return .none}
                state.repCountUnit = repCountUnit
                state.exercise.repCountUnit = repCountUnit
                let focusField: FocusField = repCountUnit == .rep ? .rep : .time
                return .send(.focusedFieldChanged(focusField))
                
                // TODO: FIXME showTabBottomSheet is set to false when deleting a workout
            case .deleteRep:
                if let rep = state.rep, state.isRepSaved {
                    state.exercise.deleteRep(rep: rep)
                }
                return .send(.delegate(.close))
            case .deleteButtonTapped:
                state.destination = .alert(.deleteRep)
                return .none
                
            case let .destination(.presented(.alert(dialog))):
                switch dialog {
                case .confirmDelete:
                    return .send(.deleteRep)
                case .cancelDelete:
                    return .none
                }
            case .destination:
                return .none
                
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
        .ifLet(\.$destination, action: \.destination)
    }
}

/**
 A view struct `RepInputView` for displaying and inputting rep details.
 */
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
                }, label: {
                    Image(systemName: store.repCountUnit == .rep ? "123.rectangle.fill" : "timer")
                        .symbolEffect(.bounce, value: store.repCountUnit)
                        .contentTransition(.symbolEffect(.replace.byLayer))
                })
                .buttonStyle(.plain)
                .disabled(store.exercise.reps.count > 0)
                
                VStack(alignment: .center) {
                    switch store.repCountUnit {
                    case .rep:
                        // MARK: Display Rep Count
                        Text(store.repCountText.isEmpty ? "0" : store.repCountText)
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(store.focusedField == .rep ? appAccentColor : Color.primary)
                            .bipAnimation(trigger: store.focusedField == .rep)
                            .contentTransition(.numericText())
                            .onTapGesture {
                                store.send(.focusedFieldChanged(.rep), animation: .customSpring())
                            }
                    case .time:
                        // MARK: Display Rep Time
                        Text(store.repTimeText.isEmpty ? "0:0" : store.repTimeText)
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(store.focusedField == .time ? appAccentColor : Color.primary)
                            .bipAnimation(trigger: store.focusedField == .rep)
                            .contentTransition(.numericText())
                            .onTapGesture {
                                store.send(.focusedFieldChanged(.time), animation: .customSpring())
                            }
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
                        .onTapGesture {
                            store.send(.focusedFieldChanged(.weight), animation: .customSpring())
                        }
                    
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
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
            .pickerStyle(.segmented)
                        
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
                        let rep = Rep(
                            weight: weight,
                            countUnit: store.repCountUnit,
                            time: repTime,
                            count: repCount,
                            weightUnit: store.weightUnit,
                            calories: calories,
                            repType: store.repType
                        )
                        store.exercise.appendRep(rep)
                        rep.exercise = store.exercise
                    }
                    
                    // Update the calories whenever a rep is added/deleted or modified
                    store.exercise.calories = Exercise.estimatedCaloriesBurned(reps: store.exercise.reps)
                    
                    if let workout = store.exercise.workout {
                        let totalCaloriesBurnedForExercise = Workout.estimatedCaloriesBurned(exercises: workout.exercises)
                        workout.calories = totalCaloriesBurnedForExercise
                        workout.abbreviatedCategory = fitnessTrackingUseCase.abbreviatedCategory(exercises: workout.exercises) ?? .none
                        workout.abbreviatedMuscle = fitnessTrackingUseCase.abbreviatedMuscle(exercises: workout.exercises) ?? .none
                    }
                    
                    store.send(.delegate(.close), animation: .default)
                } else if case CustomKey.digit(let num) = key {
                    store.send(.keypadInputReceived(num), animation: .default)
                } else if case CustomKey.delete = key {
                    store.send(.keypadDeleteButtonPressed, animation: .default)
                } else if case CustomKey.next = key {
                    store.send(.focusedFieldChanged(.weight), animation: .default)
                } else if case CustomKey.prev = key {
                    store.send(.focusedFieldChanged(store.repCountUnit == .rep ? .rep : .time), animation: .default)
                } else if case CustomKey.period = key {
                    if store.focusedField == .weight {
                        store.send(.keypadPeriodButtonPressed, animation: .default)
                    }
                }
            }, timeChangeHandler: { time in
                store.send(.repTimeChanged(time))
            })
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert) )
        .modifyIf(store.isRepSaved) {
            $0.safeAreaInset(edge: .bottom, spacing: 0) {
                VStack {
                    Divider()
                    Button(role: .destructive, action: {
                        store.send(.deleteButtonTapped, animation: .default)
                    }, label: {
                        Label("Delete", systemImage: "trash.fill")
                            .padding(.buttonContentInsets)
                    })
                    .foregroundStyle(Color.red)
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .foregroundStyle(.primary)
            }
        }
    }
    
    /**
     Retrieves the current rep input mode based on the focused field and rep count unit.
     - Returns: The current rep input mode.
     */
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

extension AlertState where Action == RepInput.Destination.Alert {
    static var deleteRep = Self {
        TextState("Delete Rep?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmDelete) {
            TextState("Yes")
        }
        ButtonState(role: .cancel, action: .cancelDelete) {
            TextState("Nevermind")
        }
    } message: {
        TextState("Are you sure you want to delete this rep?")
    }
}
