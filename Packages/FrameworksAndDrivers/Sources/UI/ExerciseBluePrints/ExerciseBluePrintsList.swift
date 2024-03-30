//
//  ExerciseBluePrintsList.swift
//
//
//  Created by harsh vishwakarma on 13/11/23.
//

import Observation
import Domain
import ApplicationServices
import Persistence
import DesignSystem
import Combine
import Foundation
import ComposableArchitecture
import SwiftData
import SwiftUI

@Reducer
public struct ExerciseBluePrintsList {
    
    @ObservableState
    public struct State: Equatable {
        var results: [ExerciseBluePrint] = []
        var selectedBluePrints: Set<ExerciseBluePrint> = Set()
        
        var searchQuery: String = ""
        var fetchDescriptor: FetchDescriptor<ExerciseBluePrint> {
            var descriptor = FetchDescriptor(predicate: self.predicate, sortBy: self.sort)
            descriptor.fetchLimit = fetchLimit
            descriptor.fetchOffset = fetchOffset
            return descriptor
        }
        
        var predicate: Predicate<ExerciseBluePrint>? {
            guard !searchQuery.isEmpty else { return nil /*#Predicate<ExerciseBluePrint> { _ in true }*/ }
            
            return #Predicate {
                $0.name.localizedStandardContains(searchQuery)
            }
        }
        
        var sort: [SortDescriptor<ExerciseBluePrint>] {
            return [
                self.nameSort?.descriptor,
                self.uuidSort?.descriptor
            ].compactMap { $0 }
        }
        
        var nameSort: NameSort?
        public enum NameSort {
            case forward, reverse
            var descriptor: SortDescriptor<ExerciseBluePrint> {
                switch self {
                case .forward:
                    return .init(\.name, order: .forward)
                case .reverse:
                    return .init(\.name, order: .reverse)
                }
            }
        }
        
        var uuidSort: UUIDSort?
        enum UUIDSort {
            case forward, reverse
            var descriptor: SortDescriptor<ExerciseBluePrint> {
                switch self {
                case .forward: return .init(\.id, order: .forward)
                case .reverse: return .init(\.id, order: .reverse)
                }
            }
        }
        
        var fetchOffset = 0
        var fetchLimit = 50
        var canFetchMore = true
        var isSearchFieldFocused: Bool = false
        
        init(results: [ExerciseBluePrint] = [], selectedBluePrints: Set<ExerciseBluePrint> = .init()) {
            self.results = results
            self.selectedBluePrints = selectedBluePrints
            self.nameSort = .forward
        }
        
        fileprivate func fetchBluePrints() -> [ExerciseBluePrint] {
            @Dependency(\.exerciseBluePrintDatabase.fetch) var fetch
            do {
                return try fetch(fetchDescriptor)
            } catch {
                Logger.state.error("\(error)")
                return []
            }
        }
        
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case fetchResults
        case loadNextPage
        case finishButtonTapped
        case selectTemplate(ExerciseBluePrint)
        case deSelectTemplate(ExerciseBluePrint)
        case searchButtonTapped
        case searchQueryChanged(String)
        case searchQueryChangeDebounced
        case delegate(Delegate)
        
        public enum Delegate {
            case didSelectBluePrints(bluePrints: [ExerciseBluePrint])
            case popToRoot
        }
    }
    
    private enum CancelID { case results }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .delegate:
                return .none
            case .fetchResults:
                let fetchResults = state.fetchBluePrints()
                let fetchLimit = state.fetchLimit
                
                state.results += fetchResults
                state.fetchOffset += fetchResults.count
                if fetchResults.count < fetchLimit {
                    state.canFetchMore = false
                }
                return .none
            case .finishButtonTapped:
                let selectedBluePrints = Array(state.selectedBluePrints)
                guard selectedBluePrints.isNotEmpty else {return .none}
                return .concatenate(.send(.delegate(.didSelectBluePrints(bluePrints: selectedBluePrints)), animation: .default), .send(.delegate(.popToRoot), animation: .default))
            case .loadNextPage:
                return .run {@MainActor send in
                    send(.fetchResults, animation: .default)
                }.cancellable(id: CancelID.results)
            case .searchButtonTapped:
                state.isSearchFieldFocused = true
                return .none
            case .selectTemplate(let template):
                state.selectedBluePrints.insert(template)
                return .none
            case .deSelectTemplate(let template):
                state.selectedBluePrints.remove(template)
                return .none
            case let .searchQueryChanged(query):
                if query != state.searchQuery {
                    state.searchQuery = query
                }
                return .none
            case .searchQueryChangeDebounced:
                state.results = []
                state.fetchOffset = 0
                state.canFetchMore = true
                return .run {@MainActor send in
                    send(.fetchResults, animation: .default)
                }.cancellable(id: CancelID.results)
            }
        }
    }
}

struct ExerciseBluePrintsListView: View {
    @Bindable var store: StoreOf<ExerciseBluePrintsList>
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(store.results) { bluePrint in
                    let isSelected = store.selectedBluePrints.contains(bluePrint)
                    NavigationLink(state: WorkoutEditorFeature.Path.State.exerciseDetails) {
                        ExerciseBluePrintRowView(exercise: bluePrint, isSelected: isSelected, highlightText: store.searchQuery)
                            .onTapGesture {
                                if isSelected {
                                    store.send(.deSelectTemplate(bluePrint))
                                } else {
                                    store.send(.selectTemplate(bluePrint))
                                }
                            }
                    }
                    .listRowSeparator(.hidden, edges: .top)
                    .listRowBackground(isSelected ? Color.secondary.opacity(0.2) : Color.clear)
                    .listRowInsets(EdgeInsets(top: 0,
                                              leading: 0,
                                              bottom: 0,
                                              trailing: 16))
                   
                }
                // FIXME: loads everytime it appears
                if store.state.canFetchMore {
                    NextPageView {
                        store.send(.loadNextPage)
                    }
                }
            }
            .listSectionSeparator(.hidden)
            .searchable(text: $store.searchQuery.sending(\.searchQueryChanged))
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: .defaultVerticalSpacing) {
                    Divider()
                    
                    HStack {
                        Button(action: {
                            // TODO:
                        }, label: {
                            Label("New Template", systemImage: "doc.fill.badge.plus")
                        })
                        
                        Spacer()
                        
                        Button(action: {
                            // TODO: Toggle Grid vs List
                        }, label: {
                            Label("Grid", systemImage: "square.grid.2x2")
                                .labelStyle(.iconOnly)
                        })
                        .foregroundStyle(.primary)
                        
                        Button(action: {
                            // TODO: Toggle selected vs All
                        }, label: {
                            Label("Selected", systemImage: "checklist.checked")
                                .labelStyle(.iconOnly)
                        })
                        
                        Button(action: {
                            // TODO: Show Filter Menu
                        }, label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle.fill")
                                .labelStyle(.iconOnly)
                        })
                    }
                    .padding(.horizontal, .defaultHorizontalSpacing)
                }
                .background(.ultraThinMaterial)
                .foregroundStyle(.primary)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                HStack {
                    if store.selectedBluePrints.isNotEmpty {
                        Button(action: {
                            store.send(.finishButtonTapped)
                        }, label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                                Text("Add \(store.selectedBluePrints.count) exercises")
                                    .foregroundStyle(.primary)
                            }
                        })
                    } else {
                        Text("Tap to add")
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .foregroundStyle(.secondary)
                    }
                    
                    
                }
            }
        }
        .bind($store.isSearchFieldFocused, to: $isSearchFieldFocused)
        .task(id: store.searchQuery) {
            do {
                try await Task.sleep(for: .milliseconds(100))
                await store.send(.searchQueryChangeDebounced).finish()
            } catch {}
        }
    }
}

#Preview {
    ExerciseBluePrintsListView(store: StoreOf<ExerciseBluePrintsList>(initialState: ExerciseBluePrintsList.State(), reducer: {
        ExerciseBluePrintsList()
    }))
}
