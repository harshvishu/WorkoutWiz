//
//  PopupPresenterView.swift
//
//
//  Created by harsh vishwakarma on 04/02/24.
//

import SwiftUI
import DesignSystem
import Domain
import ComposableArchitecture

struct EditRep {
    var exercise: Exercise?
    var rep: Rep?
}

struct AddRep {
    var exercise: Exercise?
}

@Reducer
public struct PopupPresenter {
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)
        case repInput(RepInput)
        case userWeightChangeRuler(Settings)
        case userHeightChangeRuler(Settings)
        
        public enum Alert {
            case confirmDeletion
            case continueWithoutRecording
            case openSettings
        }
    }
    
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State? = nil
    }
    
    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case addNewSet(toExercise: Exercise)
        case editSet(forExercise: Exercise, rep: Rep)
        case userWeightChangeRuler
        case userHeightChangeRuler
    }
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
                case let .addNewSet(exercise):
                    state.destination = .repInput(RepInput.State(exercise: exercise))
                    return .none
                case let .editSet(exercise, rep):
                    state.destination = .repInput(RepInput.State(exercise: exercise, rep: rep))
                    return .none
                case .destination(.presented(.repInput(.delegate(.close)))):
                    state.destination = nil
                    return .none
                    
                    // Handle user weight change from Settings screen. BMI
                case .userWeightChangeRuler:
                    state.destination = .userWeightChangeRuler(Settings.State())
                    return .none
                    
                    // Handle user height change from Settings screen. BMI
                case .userHeightChangeRuler:
                    state.destination = .userHeightChangeRuler(Settings.State())
                    return .none
                    
                case .destination:
                    return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct PopupPresenterView: View {
    @Bindable var store: StoreOf<PopupPresenter>
    
    @Environment(\.keyboardShowing) var keyboardShowing
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
        }
        .sheet(item: $store.scope(state: \.destination?.repInput, action: \.destination.repInput)) { store in
            RepInputView(store: store)
                .presentationDetents([.medium])
                .presentationContentInteraction(.resizes)
        }
        .sheet(item: $store.scope(state: \.destination?.userWeightChangeRuler, action: \.destination.userWeightChangeRuler)) { store in
            
            WeightPickerRulerView(store: store)
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .bottom))
                .presentationDetents([.medium])
                .presentationContentInteraction(.resizes)
        }
        .sheet(item: $store.scope(state: \.destination?.userHeightChangeRuler, action: \.destination.userHeightChangeRuler)) { store in
            
            HeightPickerRulerView(store: store)
            .frame(maxWidth: .infinity)
            .transition(.move(edge: .bottom))
            .presentationDetents([.medium])
            .presentationContentInteraction(.resizes)
        }
    }
}

@available(iOS 18.0, *)
#Preview {
    PopupPresenterView(store: StoreOf<PopupPresenter>(initialState: PopupPresenter.State(), reducer: {
        PopupPresenter()
    }))
}

struct HeightPickerRulerView: View {
    @Bindable var store: StoreOf<Settings>
    @State var unitTextViewSize: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .center) {
            HorizontalRulerView(config: .init(count: store.bmi.preferredHeightUnit == .centimeter ? Settings.MAX_HEIGHT_CENTIMETER : Settings.MAX_HEIGHT_FEET, steps: 10, multiplier: 1), value: .init(get: {
                return store.bmi.height
            }, set: { newValue in
                store.send(.heightChange(newValue), animation: .default)
            }))
            .frame(height: 60)
            
            TextField("Height", value: Binding(get: {
                store.bmi.height
            }, set: { weight in
                store.send(.heightChange(weight), animation: .default)
            }) , format: .number.precision(.fractionLength(2)))
            .fixedSize()
            .multilineTextAlignment(.center)
            .font(.system(size: 44, weight: .bold, design: .monospaced))
            .keyboardType(.numberPad)
            .frame(height: 240, alignment: .center)
            .contentTransition(.numericText(value: store.bmi.height))
            .overlay(alignment: .trailingFirstTextBaseline) {
                Text(store.bmi.preferredHeightUnit.sfSymbol)
                    .measureSize(size: $unitTextViewSize)
                    .foregroundStyle(.secondary)
                    .offset(x: unitTextViewSize.width)
            }
        }
    }
}

struct WeightPickerRulerView: View {
    @Bindable var store: StoreOf<Settings>
    @State var unitTextViewSize: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .center) {
            HorizontalRulerView(config: .init(count: store.bmi.preferredWeightUnit == .kg ? Settings.MAX_WEIGHT_KG : Settings.MAX_WEIGHT_POUND, multiplier: 1), value: .init(get: {
                return store.bmi.weight
            }, set: { newValue in
                store.send(.weightChange(newValue), animation: .default)
            }))
            .frame(height: 60)
                
                TextField("Weight", value: Binding(get: {
                    store.bmi.weight
                }, set: { weight in
                    store.send(.weightChange(weight), animation: .default)
                }) , format: .number.precision(.fractionLength(2)))
                .fixedSize()
                .multilineTextAlignment(.center)
                .font(.system(size: 44, weight: .bold, design: .monospaced))
                .keyboardType(.numberPad)
                .frame(height: 240, alignment: .center)
                .contentTransition(.numericText(value: store.bmi.weight))
                .overlay(alignment: .trailingFirstTextBaseline) {
                    Text(store.bmi.preferredWeightUnit.sfSymbol)
                        .measureSize(size: $unitTextViewSize)
                        .foregroundStyle(.secondary)
                        .offset(x: unitTextViewSize.width)
                }
        }
       
    }
}
