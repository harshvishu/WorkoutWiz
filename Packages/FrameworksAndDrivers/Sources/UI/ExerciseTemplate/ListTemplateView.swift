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
import SwiftData

@MainActor
struct ListTemplateView: View {
    @Environment(\.isPresented) var isPresented
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var viewModel: ListExerciseViewModel
    @State private var selectionMap: [ExerciseBluePrint: Bool] = [:]
    @State private var showNavigationBar: Bool = true
    
    @State private var isLoaded: Bool = false
    @State private var pageNumber = 0
    @State private var templates: [ExerciseBluePrint] = []
    
    var canSelect: Bool
    var searchString: String
    
    init(viewModel: ListExerciseViewModel = ListExerciseViewModel(),
                messageQueue: ConcreteMessageQueue<[ExerciseBluePrint]>? = nil,
                canSelect: Bool = false,
                searchString: String) {
        viewModel.set(messageQueue: messageQueue)
        
        self._viewModel = .init(initialValue: viewModel)
        self.canSelect = canSelect
        self.searchString = searchString
        
        // TODO: Needs improvement with selection
        
//        _templates = .init(initialValue: [])
//        _pageNumber = .init(initialValue: 0)
        _isLoaded = .init(initialValue: false)
        
//        fetchTemplates()
//        _templates = Query(filter: #Predicate {
//            if searchString.isEmpty {
//                return true
//            } else {
//                return $0.name.localizedStandardContains(searchString)
//            }
//        }, sort: [
//            SortDescriptor(\ExerciseBluePrint.frequency),
//            SortDescriptor(\ExerciseBluePrint.name, comparator: .localizedStandard)]
//        )
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            List {
                
                ForEach(templates) {
                    TemplateRowView(exercise: $0, viewModel: viewModel, selectionMap: $selectionMap)
                }
                
                if templates.isEmpty {
                    // TODO: Content unavailable view
                    VStack(alignment: .center) {
                        Text("No Exercises to Display")
                        Text("Tap to create a exercise template")
                    }
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                } else {
                    ProgressView()
                        .listRowSeparator(.hidden)
                        .task {
                            fetchTemplates()    // On appear fetch results
                        }
                }
            }
            .animation(isLoaded ? .easeInOut : nil, value: templates)
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
        .task {
            if isLoaded.not() {
                fetchTemplates()    // On appear fetch results
            }
        }
    }
}

fileprivate extension ListTemplateView {
    func getSelectedExercises() -> [ExerciseBluePrint] {
        selectionMap.compactMap { $1 ? $0 : nil }
    }
    
    func fetchTemplates() {
        let sort = [
            SortDescriptor(\ExerciseBluePrint.frequency),
            SortDescriptor(\ExerciseBluePrint.name, comparator: .localizedStandard)
        ]
        
        let predicate: Predicate<ExerciseBluePrint> = #Predicate {
            if searchString.isEmpty {
                return true
            } else {
                return $0.name.localizedStandardContains(searchString)
            }
        }
        
        let pageSize = 50
        let pageOffset = pageNumber * pageSize
        
        var descriptor = FetchDescriptor<ExerciseBluePrint>(predicate: predicate, sortBy: sort)
        descriptor.fetchLimit = pageSize
        descriptor.fetchOffset =  pageOffset
        do {
            let results = try modelContext.fetch(descriptor)
            pageNumber += 1
            templates += results
            
            if isLoaded.not() {
                isLoaded = true
            }
            
        } catch {
            print(error)
        }
    }
}

#Preview {
    return NavigationStack {
        ListTemplateView(canSelect: true, searchString: "")
            .withPreviewEnvironment()
    }
}
