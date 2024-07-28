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
import TipKit

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
            
            case confirmSave
            case cancelSave
        }
    }
    
    /**
     A state struct `State` for managing rep input related state variables.
     */
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared(.fileStorage(URL.documentsDirectory.appending(path: "bmi"))) var bmi: BMI = .init()
        
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
            self.weightUnit = bmi.preferredWeightUnit   // get the unit from user preference
            if exercise.isBodyWeightOnly {
                self.weightText = bmi.weight.isZero ? "" : String(format: hasFraction(bmi.weight) ? "%.2f" : "%.0f", bmi.weight)
            }
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
        
        func saveRep() {
            @Dependency(\.fitnessTrackingUseCase) var fitnessTrackingUseCase
            
            // Determine the weight used for the exercise. If the exercise is body-weight only, use the user's weight.
            // Otherwise, use the weight entered by the user (converted from text to double). Default to 0.0 if conversion fails.
            let weight = exercise.isBodyWeightOnly ? bmi.weight : weightText.double ?? 0.0
            
            let repCount = repCountText.int ?? 0
            let repTime = timeInterval(from: repTimeText, formatter: minutesSecondsFormatter) ?? 0.0
            
            // Calculate the calories burned using the fitness tracking use case.
            // The MET (Metabolic Equivalent of Task) value is retrieved from the exercise template category.
            
            let calories = fitnessTrackingUseCase.trackCaloriesBurned(
                metValue: exercise.template?.category.met() ?? 0.0,
                weight: weight,
                repCountUnit: repCountUnit,
                duration: repTime,
                rep: repCount
            )
            
            // If the rep already exists, update its properties with the new values.
            if let rep = rep {
                rep.weight = weight
                rep.count = repCount
                rep.time = repTime
                rep.weightUnit = weightUnit
                rep.repType = repType
                rep.countUnit = repCountUnit
                rep.calories = calories
            } else {
                // If the rep does not exist, create a new rep with the given values and add it to the exercise.
                let rep = Rep(
                    weight: weight,
                    countUnit: repCountUnit,
                    time: repTime,
                    count: repCount,
                    weightUnit: weightUnit,
                    calories: calories,
                    repType: repType
                )
                exercise.appendRep(rep)
                rep.exercise = exercise
            }
            
            // Update the calories whenever a rep is added/deleted or modified
            exercise.calories = Exercise.estimatedCaloriesBurned(reps: exercise.reps)
            
            if let workout = exercise.workout {
                let totalCaloriesBurnedForExercise = Workout.estimatedCaloriesBurned(exercises: workout.exercises)
                workout.calories = totalCaloriesBurnedForExercise
                workout.abbreviatedCategory = fitnessTrackingUseCase.abbreviatedCategory(exercises: workout.exercises) ?? .none
                workout.abbreviatedMuscle = fitnessTrackingUseCase.abbreviatedMuscle(exercises: workout.exercises) ?? .none
            }
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
        
        case keypadInputReceived(CustomKey)
    }
    
    // MARK: - Dependencies
    @Dependency(\.fitnessTrackingUseCase) var fitnessTrackingUseCase
    
    /**
     The body of the reducer, defining how actions modify the state.
     */
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            // Action to change the unit of rep count
            case let .changeRepCountUnit(repCountUnit):
                // Guard clause to prevent changing unit if reps are already added
                guard state.exercise.reps.isEmpty else {return .none}
                state.repCountUnit = repCountUnit
                state.exercise.repCountUnit = repCountUnit
                let focusField: FocusField = repCountUnit == .rep ? .rep : .time
                return .send(.focusedFieldChanged(focusField))
                
                // Action to delete a rep
            case .deleteRep:
                if let rep = state.rep, state.isRepSaved {
                    state.exercise.deleteRep(rep: rep)
                }
                return .run { @MainActor send in
                    send(.delegate(.close))
                }
            // Action when delete button is tapped
            case .deleteButtonTapped:
                state.destination = .alert(.deleteRep)
                return .none
                
            // Handling presentation of alerts
            case .destination(.presented(.alert(.confirmDelete))):
                return .send(.deleteRep)
            case .destination(.presented(.alert(.confirmSave))):
                state.saveRep()
                return .send(.delegate(.close), animation: .default)
            case .destination:
                return .none
                
            // Handling keypad input
            case let .keypadInputReceived(key):
                switch key {
                case let .digit(num):
                    switch state.focusedField {
                    // Handling digit input for rep count
                    case .some(.rep):
                        let repCountText = "\(state.repCountText)\(num)"
                        if repCountText.count > 4 {
                            return .none
                        }
                        
                        if let repCount = repCountText.int {
                            state.repCountText = (repCount == 0) ? "" : "\(repCount)"
                        }
                    // Handling digit input for weight
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
                    
                case .period:
                    if state.focusedField == .weight && !state.weightText.contains(".") {
                        state.weightText.append(".")
                    }
                    return .none
                    
                case .delete:
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
                case .switchRep, .switchTime:
                    let newRepInputMode: RepCountUnit = (state.repCountUnit == .rep) ? .time : .rep
                    return .send(.changeRepCountUnit(newRepInputMode), animation: .default)
                    
                // Action when submit button is tapped
                case .submit:
                    let weight = state.weightText.double ?? 0.0
                    let repCount = state.repCountText.int ?? 0
                    let repTime = timeInterval(from: state.repTimeText, formatter: minutesSecondsFormatter) ?? 0.0
                    
                    if weight == .zero || (repTime == 0 && repCount == 0) {
                        state.destination = .alert(.saveEmptyRep)
                        return .none
                    }
                    state.saveRep()
                    return .send(.delegate(.close), animation: .default)
                    
                case .next:
                    return .send(.focusedFieldChanged(.weight), animation: .default)
                case .prev:
                    return .send(.focusedFieldChanged(state.repCountUnit == .rep ? .rep : .time), animation: .default)
                    
                // TODO: Pending Implementations
                case .plus:
                    return .none
                case .minus:
                    return .none
                case .hideKeyboard:
                    return .none
                case .empty:
                    return .none
                case .undo:
                    return .none
                }
                
            // Action to handle focused field change
            case let .focusedFieldChanged(focusedField):
                state.focusedField = focusedField
                return .none
                
            // Action to change rep type
            case let .repTypeChanged(repType):
                state.repType = repType
                return .none
                
            // Action to change rep time
            case let .repTimeChanged(repTime):
                state.repTimeText = repTime.formattedElapsedTime(formatter: minutesSecondsFormatter)
                return .none
                
            // Action related to delegate
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
    @Bindable var store: StoreOf<RepInput>
    @State var isDeleteButtonEnabled = false
    
    let bodyWeightTip = BodyWeightTip()
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center, spacing: 4) {
                
                VStack(alignment: .center) {
                    switch store.repCountUnit {
                    case .rep:
                        // MARK: Display Rep Count
                        Text(store.repCountText.isEmpty ? "0" : store.repCountText)
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(store.focusedField == .rep ? Color.accentColor : Color.primary)
                            .bipAnimation(trigger: store.focusedField == .rep)
                            .contentTransition(.numericText())
                            .onTapGesture {
                                store.send(.focusedFieldChanged(.rep), animation: .default)
                            }
                    case .time:
                        // MARK: Display Rep Time
                        Text(store.repTimeText.isEmpty ? "0:0" : store.repTimeText)
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(store.focusedField == .time ? Color.accentColor : Color.primary)
                            .bipAnimation(trigger: store.focusedField == .rep)
                            .contentTransition(.numericText())
                            .onTapGesture {
                                store.send(.focusedFieldChanged(.time), animation: .default)
                            }
                    }
                    
                    Text("\(store.repCountUnit.description)")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                // MARK: Weight
                    VStack(alignment: .center) {
                        HStack(spacing: 0) {
                            Text(store.weightText.isEmpty ? "0" : store.weightText)
                                .font(.title.bold())
                                .bipAnimation(trigger: store.focusedField == .weight)
                                .contentTransition(.numericText())
                                .modifyIf(!store.exercise.isBodyWeightOnly) {
                                    $0
                                        .foregroundStyle(store.focusedField == .weight ? Color.accentColor : Color.primary)
                                        .onTapGesture {
                                        store.send(.focusedFieldChanged(.weight), animation: .default)
                                    }
                                }
                                .modifyIf(store.exercise.isBodyWeightOnly) {
                                    $0.offset(x: 10)
                                    .foregroundStyle(.secondary)
                                    .onTapGesture {
                                        // FIXME: needs to be fixed
//                                        Tips.showTipsForTesting([BodyWeightTip.self])
                                        print(bodyWeightTip.status, BodyWeightTip.showTip)
                                    }
                                }
                            
                            
                            if store.exercise.isBodyWeightOnly {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .offset(x: 10, y: -10)
                                    .popoverTip(bodyWeightTip, arrowEdge: .top)
                            }
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
                store.send(.keypadInputReceived(key), animation: .default)
            }, timeChangeHandler: { time in
                store.send(.repTimeChanged(time), animation: .default)
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
        } else if store.focusedField == .rep {
            return store.exercise.isBodyWeightOnly ? .repCountWithoutWeight : .repCount
        } else {
            return .timeCount
        }
    }
}


@available(iOS 18.0, *)
#Preview {
    @Previewable @State var isOn = false
    RepInputView(store: StoreOf<RepInput>(initialState: RepInput.State(exercise: Exercise()), reducer: {
        RepInput()
    }))
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
    
    static var saveEmptyRep = Self {
        TextState("Empty rep?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmSave) {
            TextState("Yes")
        }
        ButtonState(role: .cancel, action: .cancelSave) {
            TextState("Nevermind")
        }
    } message: {
        TextState("Are you sure you want to save empty rep?")
    }
}

// TODO: Remove
struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            ZStack {
                Capsule()
                    .frame(width: 28, height: 64)
                    .foregroundStyle(configuration.isOn ? Color.white : .black)
                    .overlay {
                        Capsule()
                            .stroke(Color.black.opacity(0.1), lineWidth: 2)
                    }
                ZStack{
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                    Image(systemName: configuration.isOn ? "textformat.123" : "timer")
                        .symbolVariant(.fill)
                        .contentTransition(.symbolEffect(.replace.downUp.wholeSymbol))
                }
                .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
                .offset(y: configuration.isOn ? 18 : -18)
                .padding(4)
                .animation(.spring(), value: configuration.isOn)
            }
        }
        .buttonStyle(.plain)
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable @State var isOn = false
    return Toggle("21", isOn: $isOn)
        .toggleStyle(CheckToggleStyle())
        .previewBorder()
}
