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
public struct ListExerciseTemplatesView: View {
    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
            
    @State private var viewModel: ListExerciseViewModel
    @State private var selectionMap: [ExerciseTemplate: Bool] = [:]
    @State private var showNavigationBar: Bool = true
    
    var canSelect: Bool
    
    public init(viewModel: ListExerciseViewModel = ListExerciseViewModel(),
                messageQueue: ConcreteMessageQueue<[ExerciseTemplate]>? = nil,
                canSelect: Bool = false) {
        viewModel.set(messageQueue: messageQueue)
        self._viewModel = .init(initialValue: viewModel)
        self.canSelect = canSelect
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            List {
                switch viewModel.viewState {
                case .loading:
                    ProgressView()
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .task {
                            await viewModel.listExercises()
                        }
                case .empty:
                    VStack(alignment: .center) {
                        Text("No Exercises to Display")
                        Text("Tap to create a exercise template")
                    }
                    // TODO: subscribe to some repository exercise add event
                case .display(let templates):
                    let searchResults = viewModel.searchText.isEmpty ? templates : templates.filter({$0.name.contains(viewModel.searchText)})
                    ForEach(searchResults) {
                        ExerciseTemplateRowView(exercise: $0, viewModel: viewModel, selectionMap: $selectionMap)
                    }
                }
            }
            .searchable(text: $viewModel.searchText)
        }
        .listStyle(.plain)
        .listSectionSeparator(.hidden)
        .scrollContentBackground(.hidden)
        .previewBorder()
        .toolbar(showNavigationBar ? .visible : .hidden)
        .toolbar {
            if canSelect {
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
        }
    }
}

fileprivate extension ListExerciseTemplatesView {
    func getSelectedExercises() -> [ExerciseTemplate] {
        selectionMap.compactMap { $1 ? $0 : nil }
    }
}

struct ExerciseTemplateRowView: View {
    @Environment(RouterPath.self) private var routerPath
    
    var exercise: ExerciseTemplate
    var viewModel: ListExerciseViewModel
    
    @Binding var selectionMap: [ExerciseTemplate : Bool]
    
    var body: some View {
        let isSelected = selectionMap[exercise, default: false]
        
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(exercise.name)
                        .previewBorder(Color.black.opacity(0.2))
                    Spacer()
                }
                
                let primaryMuscles = exercise.primaryMuscles.map(\.rawValue)
                if primaryMuscles.isNotEmpty {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Primary Muscles")
                            .bold()
                        Text(primaryMuscles, format: .list(type: .and))
                            .lineLimit(1)
                            .previewBorder(.red.opacity(0.2))
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                }
                
                let secondaryMuscles = exercise.secondaryMuscles.map(\.rawValue)
                if secondaryMuscles.isNotEmpty {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Secondary Muscles")
                            .bold()
                        Text(secondaryMuscles, format: .list(type: .and))
                            .lineLimit(1)
                            .previewBorder(.red.opacity(0.2))
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                }
            }
            
            if let image = viewModel.imageUrlFor(exercise: exercise).first {
                AsyncImage(url: image)
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: .exerciseTemplatePreviewImageSize, height: .exerciseTemplatePreviewImageSize)
                    .clipShape(RoundedRectangle(cornerRadius: .exerciseTemplatePreviewImageCornerRadius))
                    .print(image)
                    .overlay {
                        RoundedRectangle(cornerRadius: .exerciseTemplatePreviewImageCornerRadius)
                            .fill(Color.clear)
                            .stroke(.tertiary, lineWidth: 0.5)
                            .shadow(color: .secondary.opacity(0.1), radius: 20, x: 0.0, y: 2.0)
                    }
            }
            
            Button(action: {
                debugPrint("button tap \(#file) \(#line)")
                routerPath.navigate(to: .exerciseDetails(exercise))
            }, label: {
                Image(systemName: "info.circle")
            })
            .tint(.primary)
            .buttonStyle(.borderless)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            debugPrint("gesture tap \(#file) \(#line)")
            withCustomSpring {
                selectionMap[exercise] = !isSelected
            }
        }
        .previewBorder(Color.accentColor.opacity(0.2))
        .selectableRow(isSelected: isSelected)
        .id(exercise.id)
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
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                .contentTransition(.symbolEffect(.replace.byLayer.offUp))
                .symbolEffect(.bounce, value: isSelected)
                .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                .layoutPriority(0)
                .previewBorder(Color.blue.opacity(0.2))
            
            content
                .layoutPriority(1)
        }
        .previewBorder(Color.green.opacity(0.2))
    }
}

#Preview {
    return NavigationStack {
        ListExerciseTemplatesView(canSelect: true)
            .withPreviewEnvironment()
    }
}

#Preview("ExerciseTemplateRowView") {
    @State var selectionMap: [ExerciseTemplate: Bool] = [.mock_1: true]
    return ExerciseTemplateRowView(
        exercise: .mock_1,
        viewModel: ListExerciseViewModel(),
        selectionMap: $selectionMap
    )
    .withPreviewEnvironment()
}
