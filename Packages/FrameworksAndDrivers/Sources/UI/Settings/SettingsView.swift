//
//  SettingsView.swift
//
//
//  Created by harsh vishwakarma on 01/04/24.
//

import SwiftUI
import ComposableArchitecture
import Domain
import Persistence
import DesignSystem

fileprivate extension SaveDataManager.Keys {
    static let user_bmi = "user_bmi"
}
public extension Settings {
    static let MAX_WEIGHT_KG = 300
    static let MAX_WEIGHT_POUND = 661
    
    static let MIN_WEIGHT_KG = 20
    static let MIN_WEIGHT_POUND = 25
    
    static let MAX_HEIGHT_CENTIMETER = 300
    static let MAX_HEIGHT_FEET = 9
    
    static let MIN_HEIGHT_CENTIMETER = 50
    static let MIN_HEIGHT_FEET = 1
}

@Reducer
public struct Settings {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.fileStorage(URL.documentsDirectory.appending(path: "bmi"))) var bmi: BMI = .init()
        
        init(bmi: BMI) {
            self.bmi = bmi
        }
        
        init() {
        }
        
    }
    
    public enum Action: Equatable {
        case heightChange(Double)
        case weightChange(Double)
        case heightUnitChange(HeightUnit)
        case weightUnitChange(WeightUnit)
        
        case delegate(Delegate)
        @CasePathable
        public enum Delegate {
            case heightPickerRuler
            case weightPickerRuler
        }
    }
    
    // MARK: - Dependencies
    @Dependency(\.saveData) var saveData
    
    public var body: some ReducerOf<Self> {
        
        Reduce<State, Action> {
            state,
            action in
            switch action {
                case .heightChange(let height):
                    state.bmi.height = height.clamped(
                        to: state.bmi.preferredHeightUnit == .centimeter ?
                        (Double(Settings.MIN_HEIGHT_CENTIMETER)...Double(Settings.MAX_HEIGHT_CENTIMETER)) :
                            (Double(Settings.MIN_HEIGHT_FEET)...Double(Settings.MAX_HEIGHT_FEET))
                    )
                    return .none
                    
                case .weightChange(let weight):
                    state.bmi.weight =  weight.clamped(
                        to: state.bmi.preferredWeightUnit == .kg ?
                        (Double(Settings.MIN_WEIGHT_KG)...Double(Settings.MAX_WEIGHT_KG)) :
                            (Double(Settings.MIN_WEIGHT_POUND)...Double(Settings.MAX_WEIGHT_POUND))
                    )
                    return .none
                    
                case .heightUnitChange(let unit):
                    guard unit != state.bmi.preferredHeightUnit else {return .none}
                    state.bmi.preferredHeightUnit = unit
                    let newHeight = unit.convertInto(state.bmi.height)
                    
                    return .run { @MainActor send in
                        send(.heightChange(newHeight), animation: .default)
                    }
                    
                case .weightUnitChange(let unit):
                    guard unit != state.bmi.preferredWeightUnit else {return .none}
                    state.bmi.preferredWeightUnit = unit
                    let newWeight = unit.convertInto(state.bmi.weight)
                    
                    return .run { @MainActor send in
                        send(.weightChange(newWeight), animation: .default)
                    }
                    
                case .delegate:
                    return .none
            }
        }
    }
}

struct SettingsView: View {
    @Bindable var store: StoreOf<Settings>
    
    var body: some View {
        NavigationStack {
            Form {
                Section("BMI") {
                    
                    LabeledContent("Weight") {
                        Button {
                            store.send(.delegate(.weightPickerRuler))
                        } label: {
                            let weight: Measurement<UnitMass> = Measurement(value: store.bmi.weight, unit: store.bmi.preferredWeightUnit.systemUnit())
                            Text(weight.formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(2)))))
                        }
                        .contentTransition(.numericText(value: store.bmi.weight))
                        .animation(.snappy, value: store.bmi.weight)
                        .frame(maxWidth:  .infinity, alignment: .trailing)
                        
                        Menu {
                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                Button {
                                    store.send(.weightUnitChange(unit))
                                } label: {
                                    Text(unit.name)
                                }
                            }
                        } label: {
                            Image(systemName: "scalemass")
                                .frame(width: 25)
                        }
                    }
                    
                    LabeledContent("Height") {
                        Button {
                            store.send(.delegate(.heightPickerRuler))
                        } label: {
                            let height: Measurement<UnitLength> = Measurement(value: store.bmi.height, unit: store.bmi.preferredHeightUnit.systemUnit())
                            Text(height.formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(2)))))
                        }
                        .contentTransition(.numericText(value: store.bmi.height))
                        .animation(.snappy, value: store.bmi.height)
                        .frame(maxWidth:  .infinity, alignment: .trailing)
                        
                        Menu {
                            ForEach(HeightUnit.allCases, id: \.self) { unit in
                                Button {
                                    store.send(.heightUnitChange(unit))
                                } label: {
                                    Text(unit.name)
                                }
                            }
                        } label: {
                            Image(systemName: "ruler")
                                .frame(width: 25)
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
            
            .navigationBarTitle("Settings")
        }
    }
    
}

@available(iOS 18.0, *)
#Preview {
    SettingsView(store: StoreOf<Settings>(initialState: Settings.State(), reducer: {
        Settings()
    }, withDependencies: {
        $0.saveData = .previewValue
    }))
}
