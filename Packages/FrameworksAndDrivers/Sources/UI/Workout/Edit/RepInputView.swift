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

@MainActor
struct RepInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) var appState
    
    @State private var fitnessTrackingUseCase: FitnessTrackingIOPort = FitnessTrackingUseCase()
    
    var exercise: Exercise
    var rep: Rep?
    var onClose: () -> Void
    
    init(exercise: Exercise, onClose: @escaping () -> Void) {
        self.exercise = exercise
        self.onClose = onClose
        
        // TODO: Use save manager to get last saved info
        self._repCount = .init(initialValue: 0)
        self._repTime = .init(initialValue: 0.0)
        self._weight = .init(initialValue: 5)
        self._repCountUnit = .init(initialValue: exercise.repCountUnit)
        self._weightUnit = .init(initialValue: .kg)
        self._repType = .init(initialValue: .none)
        _val = .init(initialValue: "")
        
        switch exercise.repCountUnit {
        case .rep:
            _focusedField = .init(initialValue: .rep)
        case .time:
            _focusedField = .init(initialValue: .time)
        }
    }
    
    init(exercise: Exercise, rep: Rep, onClose: @escaping () -> Void) {
        self.exercise = exercise
        self.rep = rep
        self.onClose = onClose
        
        self._repCount = .init(initialValue: rep.count)
        self._repTime = .init(initialValue: rep.time)
        self._weight = .init(initialValue: rep.weight)
        self._repCountUnit = .init(initialValue: rep.countUnit)
        self._weightUnit = .init(initialValue: rep.weightUnit)
        self._repType = .init(initialValue: rep.repType)
        
        switch rep.countUnit {
        case .rep:
            _val = .init(initialValue: "\(rep.count)")
            _focusedField = .init(initialValue: .rep)
        case .time:
            _val = .init(initialValue: rep.time.formattedElapsedTime())
            _focusedField = .init(initialValue: .time)
        }
    }
    
    @State var repCount: Int
    @State var repTime: TimeInterval
    @State var weight: Double
    @State var repCountUnit: RepCountUnit
    @State var weightUnit: WeightUnit
    @State var repType: RepType
    @State var val: String = ""
    
    @State var isRepCountFocused: Bool = true
    @State var focusedField: FocusField?
    @State var repInputMode: RepInputMode = .repCount
        
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 4) {
                
                Button(action: {
                    // TODO: change rep input mode for set
                    // Also change if exercise does not have any rep
                    withCustomSpring {
                        let newRepInputMode: RepCountUnit = (repInputMode == .repCount) ? .time : .rep
                        if exercise.reps.isEmpty {
                            exercise.repCountUnit = newRepInputMode
                            repCountUnit = newRepInputMode
                        }
                    }
                   
                }, label: {
                    Image(systemName: repCountUnit == .rep ? "123.rectangle.fill" : "timer")
                        .symbolEffect(.bounce, value: repCountUnit)
                        .contentTransition(.symbolEffect(.replace.byLayer))
                })
                .buttonStyle(.plain)
                .disabled(exercise.reps.count > 0)
                
                VStack(alignment: .center) {
                    switch repCountUnit {
                    case .time:
                        Text(repTime.formattedElapsedTime(formatter: minutesSecondsFormatter))
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(focusedField == .time ? appAccentColor : Color.primary)
                            .bipAnimation(trigger: focusedField == .rep)
                        
                    case .rep:
                        Text(repCount, format: .number)
                            .font(.title.bold())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(focusedField == .rep ? appAccentColor : Color.primary)
                            .bipAnimation(trigger: focusedField == .rep)
                    }
                    
                    Text("\(repCountUnit.description)")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(alignment: .center) {
                    Text(weight, format: .number.precision(.fractionLength(2)))
                        .font(.title.bold())
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(focusedField == .weight ? appAccentColor : Color.primary)
                        .bipAnimation(trigger: focusedField == .weight)
                    
                    Text("\(weightUnit.sfSymbol)")
                        .font(.caption2)
                }
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
            .frame(maxWidth: .infinity)
           
            Divider()
            
            Picker(selection: $repType, label: Text("Mark set as")) {
                ForEach(RepType.allCases, id:\.self) {
                    Text($0.description)
                        .tag($0.rawValue)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .pickerStyle(.segmented)
            
            Divider()
            
            RepInputKeyboard(value: $val, mode: $repInputMode, keyPressHandler:  { key in
                if case .submit = key {
                    
                    let calories = fitnessTrackingUseCase.trackCaloriesBurned(
                        metValue: exercise.template?.category.met() ?? 0.0,
                        weight: weight,
                        repCountUnit: repCountUnit,
                        duration: repTime,
                        rep: repCount
                    )
                    
                    if let rep = rep {
                        rep.weight = weight
                        rep.count = repCount
                        rep.time = repTime
                        rep.weightUnit = weightUnit
                        rep.repType = repType
                        rep.countUnit = repCountUnit
                        rep.calories = calories
                    } else {
                        let position = exercise.reps.count
                        
                        let rep = Rep(
                            weight: weight,
                            countUnit: repCountUnit,
                            time: repTime,
                            count: repCount,
                            weightUnit: weightUnit,
                            calories: calories,
                            position: position,
                            repType: repType
                        )
                        exercise.reps.append(rep)
                        rep.exercise = exercise
                    }
                    
                    // Update the calories whenever a rep is added/ deleted or modified
                    // TODO: Delete REP is pending
                    exercise.calories = Exercise.estimatedCaloriesBurned(reps: exercise.reps)
                    
                    if let workout = exercise.workout {
                        let totalCaloriesBurnedForExercise = Workout.estimatedCaloriesBurned(exercises: workout.exercises)
                        workout.calories = totalCaloriesBurnedForExercise
                    }
                                        
                    onClose()
                } else if case CustomKey.digit(let num) = key {
                    let finalVal = val.appending("\(num)")
                    if finalVal.int != nil && finalVal.count < 5 {    // is a valid INteger
                        val = finalVal
                    }
                } else if case CustomKey.delete = key {
                    if val.count > 0 {  // No more delete
                        val.removeLast()
                    }
                } else if case CustomKey.next = key {
                    
                    withAnimation(/*.spring().repeatCount(1, autoreverses: true)*/) {
                        if focusedField == .weight {
                            focusedField = repCountUnit == .rep ? .rep : .time
                        } else {
                            focusedField = .weight
                        }
                    }
                }
            }, timeChangeHandler: { time in
                repTime = time
            })
        }
        .onChange(of: repCountUnit, initial: true, { oldValue, newValue in
            switch newValue {
            case .rep:
                repInputMode = .repCount
                if focusedField != .weight {
                    focusedField = .rep
                }
            case .time:
                repInputMode = .timeCount
                if focusedField != .weight {
                    focusedField = .time
                }
            }
        })
        .background(
            UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: .sheetCornerRadius, bottomLeading: 0, bottomTrailing: 0, topTrailing: .sheetCornerRadius))
                .fill(.background)
                .ignoresSafeArea(.all)
                .shadow(color: .primary.opacity(0.25), radius: 20, x: 0.0, y: 2.0)
        )
        .safeAreaInset(edge: .bottom) {
            EmptyView()
                .frame(height: 0)
        }
        .onChange(of: val) { _, newValue in
            switch repCountUnit {
            case .rep:
                repCount = newValue.int ?? 0
            case .time:
                let time = TimeInterval(newValue.double ?? 0.0)
                repTime = time
            }
        }
    }
}

enum FocusField: Hashable {
    case time
    case rep
    case weight
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
