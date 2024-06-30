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
//        var bmi: BMI = .init()
//        @Shared(.appStorage("weight")) var weight = 2
        @Shared(.fileStorage(URL.documentsDirectory.appending(path: "bmi"))) var bmi: BMI = .init()
        
        init(bmi: BMI) {
            self.bmi = bmi
        }
        
        init() {
            fetchBMI()
        }
        
        private mutating func fetchBMI() {
//            @Dependency(\.saveData) var saveData
//            self.bmi = saveData.load(forKey: SaveDataManager.Keys.user_bmi) ?? .init()
        }
    }
    
    public enum Action: Equatable {
        case heightChange(Double)
        case weightChange(Double)
        
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
        
        Reduce<State, Action> { state, action in
            switch action {
            case .heightChange(let height):
                state.bmi.height = height
                return .none
            case .weightChange(let weight):
                state.bmi.weight = weight
                return .none
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
                        HStack {
                            
                            Button {
                                store.send(.delegate(.weightPickerRuler))
                            } label: {
                                Text(store.bmi.weight, format: .number)
                            }
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
                        }
                    }
                    
                    
                    LabeledContent("Height") {
                        HStack {
                            
                            Button {
                                store.send(.delegate(.heightPickerRuler))
                            } label: {
                                Text(store.bmi.height, format: .number)
                            }
                            .contentTransition(.numericText(value: store.bmi.height))
                            .animation(.snappy, value: store.bmi.height)
                            
                            
                            Menu {
                                ForEach(HeightUnit.allCases, id: \.self) {
                                    Text($0.sfSymbol)
                                }
                            } label: {
                                Image(systemName: "scalemass")
                                    .symbolVariant(.fill)
                            }
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
