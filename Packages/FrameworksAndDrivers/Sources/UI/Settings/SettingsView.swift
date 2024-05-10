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

@Reducer
public struct Settings {
    
    @ObservableState
    public struct State: Equatable {
        var bmi: BMI = .init()
        
        init(bmi: BMI) {
            self.bmi = bmi
        }
        
        init() {
            fetchBMI()
        }
        
        private mutating func fetchBMI() {
            @Dependency(\.saveData) var saveData
            self.bmi = saveData.load(forKey: SaveDataManager.Keys.user_bmi) ?? .init()
        }
    }
    
    public enum Action: Equatable {
        case heightChange(Double)
        case weightChange(Double)
        
        case saveChanges
    }
    
    // MARK: - Dependencies
    @Dependency(\.saveData) var saveData
    
    public var body: some ReducerOf<Self> {
        
        Reduce<State, Action> { state, action in
            switch action {
            case .heightChange(let height):
                state.bmi.height = height
                return .send(.saveChanges)
            case .weightChange(let weight):
                state.bmi.weight = weight
                return .send(.saveChanges)
            case .saveChanges:
                saveData.save(state.bmi, forKey: SaveDataManager.Keys.user_bmi)
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
                        HStack {
                            TextField("Weight", value: Binding(get: {
                                store.bmi.weight
                            }, set: { height in
                                store.send(.weightChange(height), animation: .default)
                            }) , format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .contentTransition(.numericText(value: store.bmi.weight))
                            .animation(.snappy, value: store.bmi.weight)
                            
                            Menu {
                                ForEach(WeightUnit.allCases, id: \.self) {
                                    Text($0.sfSymbol)
                                }
                            } label: {
                                Image(systemName: "scalemass")
                                    .symbolVariant(.fill)
                            }
                            .foregroundStyle(.primary)
                            
//                            .overlay(alignment: .center) {
//                                Text("Kg")
//                                    .font(.footnote)
//                                    .fontWeight(.semibold)
//                                    .foregroundStyle(.background)
//                                    .fixedSize()
//                            }
                            
                            //                            WheelPicker(config: .init(count: 200, multiplier: 1), value: $store.bmi.weight.sending(\.weightChange))
                            //                                .frame(height: 60)
                        }
                    }
                    
                    
                    LabeledContent("Height") {
                        HStack {
                            TextField("Height", value: Binding(get: {
                                store.bmi.height
                            }, set: { height in
                                store.send(.heightChange(height), animation: .default)
                            }) , format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .contentTransition(.numericText(value: store.bmi.height))
                            .animation(.snappy, value: store.bmi.height)
                            
                            Button(action: {}, label: {
                                Image(systemName: "ruler")
                                    .symbolVariant(.fill)
                            })
                            .foregroundStyle(.primary)
                        }
                    }
                    
                }
            }
            .listRowSeparator(.hidden)
            .navigationBarTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(store: StoreOf<Settings>(initialState: Settings.State(), reducer: {
        Settings()
    }, withDependencies: {
        $0.saveData = .previewValue
    }))
}
