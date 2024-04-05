//
//  ExerciseRowView.swift
//
//
//  Created by harsh vishwakarma on 13/12/23.
//

import Domain
import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import ComposableArchitecture

@Reducer
public struct ExerciseRow {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: ObjectIdentifier {
            exercise.id
        }
        var exercise: Exercise
    }
    
    public enum Action {
        case delegate(Delegate)
        
        public enum Delegate {
            case addNewSet
            case editSet(Rep)
        }
    }
}

public struct ExerciseRowView: View {
    let store: StoreOf<ExerciseRow>
    
    @State private var showExpandedSetView = true
    @State private var messageQueue: ConcreteMessageQueue<(Rep,Int)> = .init()
    
    var isEditable: Bool
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                ExerciseRowHeaderView(store: store, isExpanded: $showExpandedSetView)
                    .padding(.bottom, 4)
                
                ForEachWithIndex(store.exercise.reps) { idx, rep in
                    ExerciseRepRowView(set: rep, position: idx)
                        .transition(.move(edge: .bottom))
                        .onTapGesture {
                            store.send(.delegate(.editSet(rep)))
                        }
                }
                
                if store.exercise.reps.isNotEmpty {
                    HStack {
                        Text("\(store.exercise.repCountUnit.description)")
                            .font(.caption2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("kg")  // TODO: Get the default unit set for this exercise
                            .font(.caption2)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 8)
                    }
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .bottom))
                }
            }
            .padding(.listRowContentInset)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.tertiary, lineWidth: 0.5)
                    .fill(.background)
                    .padding(0.5)
            }
            
            // Footer
            ExerciseRowFooterView(store: store, isEditable: isEditable)
                .zIndex(-1)
        }
    }
}
