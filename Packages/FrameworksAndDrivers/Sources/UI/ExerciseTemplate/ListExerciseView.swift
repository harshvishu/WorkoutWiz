//
//  ListExerciseView.swift
//  
//
//  Created by harsh vishwakarma on 13/11/23.
//

import SwiftUI
import Domain
import ApplicationServices
import Persistence
import DesignSystem

@MainActor
public struct ListExerciseView: View {
    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
    
    @State var viewModel: ListExerciseViewModel
    
    /// List selection properties
    @State var selectionMap: [ExerciseTemplate: Bool] = [:]
    @State var canSelect: Bool = true
    
    public init(viewModel: ListExerciseViewModel = ListExerciseViewModel(),
                messageQueue: ConcreteMessageQueue<[ExerciseTemplate]>? = nil) {
        viewModel.set(messageQueue: messageQueue)
        self._viewModel = .init(initialValue: viewModel)
    }
    
    public var body: some View {
        VStack {
            List(viewModel.exercies) {
               ExerciseTemplateRowView(exercise: $0, selectionMap: $selectionMap)
            }
        }
        .listStyle(.plain)
        .listSectionSeparator(.hidden)
//        .listRowSpacing(.listRowVerticalSpacing)
        .scrollContentBackground(.hidden)
        .debugBorder()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button(action: {
                        viewModel.didSelect(exercises: getSelectedExercises())
                        dismiss()
                    }, label: {
                        Image(systemName: "checkmark")
                            .contentTransition(.symbolEffect(.replace.downUp.byLayer))
                            .foregroundStyle(.secondary)
                    })
                    .foregroundStyle(.primary)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                }
                .showIf(getSelectedExercises().isNotEmpty)
            }
            
        }
        // On Appear Tasks
        .task(priority: .background) {
            await viewModel.listExercises()
        }
    }
}

fileprivate extension ListExerciseView {
    func getSelectedExercises() -> [ExerciseTemplate] {
        selectionMap.compactMap { $1 ? $0 : nil }
    }
}

struct ExerciseTemplateRowView: View {
    var exercise: ExerciseTemplate
    
    @Binding var selectionMap: [ExerciseTemplate : Bool]
    
    var body: some View {
        let isSelected = selectionMap[exercise, default: false]
        
        Text(exercise.name)
            .background(Color.clear)
            .selectableRow(isSelected: isSelected)
            .id(exercise.id)
            .contentShape(Rectangle())
            .onTapGesture {
                withCustomSpring {
                    selectionMap[exercise] = !isSelected
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

extension View {
    func selectableRow(isSelected: Bool) -> some View {
        modifier(SelectableRowItem(isSelected: isSelected))
    }
}

struct SelectableRowItem: ViewModifier {
    var isSelected: Bool = false
    
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                .contentTransition(.symbolEffect(.replace.downUp.byLayer))
        }
    }
}
