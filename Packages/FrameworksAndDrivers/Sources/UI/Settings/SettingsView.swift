//
//  SettingsView.swift
//  
//
//  Created by harsh vishwakarma on 01/04/24.
//

import SwiftUI 
import ComposableArchitecture
import Domain

@Reducer
public struct Settings {
    
    @ObservableState
    public struct State: Equatable {
        var bmi: BMI = .init()
        
        init(bmi: BMI) {
            self.bmi = bmi
        }
        
        init() {}
        
        private mutating func fetchBMI() {
            @Dependency(\.bmi) var bmi
            self.bmi = bmi
        }
    }
    
    public enum Action: Equatable {
        case heightChange(Double)
        case weightChange(Double)
        
        case saveChanges
    }
        
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
                state.bmi.save()
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
                        TextField("70.0", value: Binding(get: {
                            store.bmi.weight
                        }, set: { weight in
                            store.send(.weightChange(weight), animation: .default)
                        }) , format: .number.precision(.fractionLength(2)))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numbersAndPunctuation)
                    }
                    
                    LabeledContent("Height") {
                        TextField("Height", value: Binding(get: {
                            store.bmi.height
                        }, set: { height in
                            store.send(.heightChange(height), animation: .default)
                        }) , format: .number.precision(.fractionLength(2)))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numbersAndPunctuation)
                    }
                }
                .hideNativeTabBar()
            }
            .navigationBarTitle("Settings")
        }
    }
}

//#Preview {
//    SettingsView(store: StoreOf<Settings>(initialState: Settings.State(), reducer: {
//        Settings()
//    }, withDependencies: {
//        $0.saveData = .previewValue
//    }))
//}
