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
        // MARK: - Properties
        
        // Array to hold all fetched exercise blueprints
        var results: [ExerciseBluePrint] = []
        
        // Array to hold exercise blueprints to be displayed
        var displayResults: [ExerciseBluePrint] = []
        
        // Array to hold recently accessed exercise blueprints
        var recentResults: [ExerciseBluePrint] = []
        
        // Set to store selected exercise blueprints
        var selectedBluePrints: Set<ExerciseBluePrint> = Set()
        
        // Search query string
        var searchQuery: String = ""
        
        // Descriptor for fetching exercise blueprints
        var fetchDescriptor: FetchDescriptor<ExerciseBluePrint> {
            var descriptor = FetchDescriptor(predicate: self.predicate, sortBy: self.sort)
            descriptor.fetchLimit = pageSize
            descriptor.fetchOffset = pageOffset
            return descriptor
        }
        
        // Predicate for filtering exercise blueprints based on search query
        var predicate: Predicate<ExerciseBluePrint>? {
            guard !searchQuery.isEmpty else { return nil }
            return #Predicate {
                $0.searchString.localizedStandardContains(searchQuery)
            }
        }
        
        // Sort descriptors for exercise blueprints
        var sort: [SortDescriptor<ExerciseBluePrint>] {
            return [
                self.nameSort.descriptor,
                self.frequencySort.descriptor
            ]
        }
        
        // Enum to specify sorting by name
        var nameSort: NameSort = .forward
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
        
        // Enum to specify sorting by frequency
        var frequencySort: FrequencySort = .forward
        enum FrequencySort {
            case forward, reverse
            var descriptor: SortDescriptor<ExerciseBluePrint> {
                switch self {
                case .forward: return .init(\.frequency, order: .forward)
                case .reverse: return .init(\.frequency, order: .reverse)
                }
            }
        }
        
        // Offset for fetching exercise blueprints
        var pageOffset = 0
        
        // Limit for fetching exercise blueprints
        var pageSize = 50
        
        // Flag indicating whether more exercise blueprints can be fetched
        var canFetchMore = true
        
        // Flag indicating if the search field is focused
        var isSearchFieldFocused: Bool = false
        
        // MARK: - Filter Properties
        
        // Array to hold filtered muscles for exercise blueprints
        var filterMuscles: [ExerciseMuscles] = []
        
        // Array to hold filtered equipment for exercise blueprints
        var filterEquipments: [ExerciseEquipment] = []
        
        // Flag indicating whether to display only selected exercise blueprints
        var showOnlySelected: Bool = false
        
        // MARK: - Initializer
        
        // Initializer with default parameter values
        init(results: [ExerciseBluePrint] = [], selectedBluePrints: Set<ExerciseBluePrint> = .init()) {
            self.results = results
            self.selectedBluePrints = selectedBluePrints
        }
        
        // MARK: - Fetching Functions
        
        // Function to fetch exercise blueprints
        fileprivate func fetchBluePrints() -> [ExerciseBluePrint] {
            @Dependency(\.exerciseBluePrintDatabase.fetch) var fetch
            do {
                return try fetch(fetchDescriptor)
            } catch {
                Logger.state.error("\(error)")
                return []
            }
        }
        
        // Function to fetch recently accessed exercise blueprints
        fileprivate func fetchRecentBluePrints() -> [ExerciseBluePrint] {
            @Dependency(\.exerciseBluePrintDatabase.fetch) var fetch
            do {
                var descriptor = FetchDescriptor<ExerciseBluePrint>(predicate: #Predicate {
                    $0.frequency > 1
                }, sortBy: [frequencySort.descriptor])
                descriptor.fetchLimit = 10
                
                return try fetch(descriptor)
            } catch {
                Logger.state.error("\(error)")
                return []
            }
        }
    }
    
    public enum Action: BindableAction {
        // MARK: - Action Cases
        
        // Binding action case to update state binding
        case binding(BindingAction<State>)
        
        // Action to deselect a template exercise blueprint
        case deSelectTemplate(ExerciseBluePrint)
        
        // Action to delegate an action to another component
        case delegate(Delegate)
        
        // Action to fetch results (exercise blueprints)
        case fetchResults
        
        // Action when the finish button is tapped
        case finishButtonTapped
        
        // Action to filter results based on criteria
        case filterResults
        
        // Action to load the next page of results
        case loadNextPage
        
        // Action when the search query changes
        case searchQueryChanged(String)
        
        // Action to debounce the search query change
        case searchQueryChangeDebounced
        
        // Action to select a template exercise blueprint
        case selectTemplate(ExerciseBluePrint)
        
        // Action to toggle the filter for equipment
        case toggleEquipmentFilter(forEquipment: ExerciseEquipment)
        
        // Action to toggle showing only selected exercise blueprints
        case toggleShowOnlySelected(Bool)
        
        // Action to toggle the filter for muscle
        case toggleMuscleFilter(forMuscle: ExerciseMuscles)
        
        // MARK: - Delegate Cases
        
        // Delegate cases for handling delegation actions
        public enum Delegate {
            // Delegate action when blueprints are selected
            case didSelectBluePrints(bluePrints: [ExerciseBluePrint])
            
            // Delegate action to pop to the root component
            case popToRoot
        }
    }
    
    private enum CancelID { case results, search }
    
    public var body: some Reducer<State, Action> {
        // Define the body of the reducer
        Reduce { state, action in
            // Switch over the action cases
            switch action {
                // Handle binding actions
            case .binding:
                // No action needed for binding
                return .none
                
                // Handle delegation actions
            case .delegate:
                // No action needed for delegation
                return .none
                
                // Handle search query change action
            case let .searchQueryChanged(query):
                // Trim leading and trailing whitespace from the query
                let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
                // Check if the query has changed
                if query != state.searchQuery {
                    // Update the search query in the state
                    state.searchQuery = query
                    // Send a debounced action for search query change
                    return .send(.searchQueryChangeDebounced, animation: .default).debounce(id: CancelID.search, for: 0.5, scheduler: DispatchQueue.main)
                } else {
                    // No action needed if the query hasn't changed
                    return .none
                }
                
                // Handle selecting a template action
            case .selectTemplate(let template):
                // Insert the selected template into the set of selected blueprints
                state.selectedBluePrints.insert(template)
                return .none
                
                // Handle deselecting a template action
            case .deSelectTemplate(let template):
                // Remove the deselected template from the set of selected blueprints
                state.selectedBluePrints.remove(template)
                return .none
                
                // Handle filtering results action
            case .filterResults:
                // Update displayed results based on showOnlySelected flag
                if state.showOnlySelected {
                    state.displayResults = Array(state.selectedBluePrints)
                } else {
                    // Filter results based on search query, muscles, and equipment
                    var filteredResults = state.results
                    let searchQuery = state.searchQuery
                    let muscleSearchQueries = state.filterMuscles.map { $0.rawValue }
                    let equipmentSearchQueries = state.filterEquipments.map { $0.rawValue }
                    let filterParameters = [muscleSearchQueries, equipmentSearchQueries].flatMap { $0 }
                    
                    if filterParameters.isNotEmpty || searchQuery.isNotEmpty {
                        filteredResults = filteredResults.filter { template in
                            let matchesFilterParameters = if filterParameters.isNotEmpty {
                                filterParameters.contains { template.searchString.localizedCaseInsensitiveContains($0) }
                            } else {
                                true
                            }
                            
                            let matchesSearchQuery = searchQuery.isNotEmpty ? template.name.localizedStandardContains(searchQuery) : true
                            
                            return matchesFilterParameters && matchesSearchQuery
                        }
                    }
                    state.displayResults = filteredResults
                }
                return .none
                
                // Handle fetching results action
            case .fetchResults:
                // Fetch exercise blueprints
                let fetchResults = state.fetchBluePrints()
                let pageSize = state.pageSize
                // Update state with fetched results
                state.results += fetchResults
                state.pageOffset += fetchResults.count
                // Check if more results can be fetched
                if fetchResults.count < pageSize {
                    state.canFetchMore = false
                }
                // Fetch recent exercise blueprints
                state.recentResults = state.fetchRecentBluePrints()
                // Send filter results action
                return .send(.filterResults, animation: .default)
                
                // Handle finish button tapped action
            case .finishButtonTapped:
                // Get selected blueprints
                let selectedBluePrints = Array(state.selectedBluePrints)
                // Check if any blueprints are selected
                guard selectedBluePrints.isNotEmpty else { return .none }
                // Concatenate actions to send delegate action and pop to root action
                return .run { send in
                    await send(.delegate(.didSelectBluePrints(bluePrints: selectedBluePrints)), animation: .default)
                    await send(.delegate(.popToRoot), animation: .default)
                }
                
                // Handle loading next page action
            case .loadNextPage:
                // Run action to fetch results
                return .run { @MainActor send in
                    send(.fetchResults, animation: .default)
                }.cancellable(id: CancelID.results)
                
                // Handle debounced search query change action
            case .searchQueryChangeDebounced:
                // Reset results, offset, and flag to allow fetching more results
                state.results = []
                state.displayResults = []
                state.pageOffset = 0
                state.canFetchMore = true
                // Run action to fetch results
                return .run { @MainActor send in
                    send(.fetchResults, animation: .default)
                }.cancellable(id: CancelID.results)
                
                // Handle toggling muscle filter action
            case .toggleMuscleFilter(let muscle):
                // Toggle muscle filter
                if let index = state.filterMuscles.firstIndex(of: muscle) {
                    state.filterMuscles.remove(at: index)
                } else {
                    state.filterMuscles.append(muscle)
                }
                // Send filter results action
                return .send(.filterResults, animation: .default)
                
                // Handle toggling equipment filter action
            case .toggleEquipmentFilter(let equipment):
                // Toggle equipment filter
                if let index = state.filterEquipments.firstIndex(of: equipment) {
                    state.filterEquipments.remove(at: index)
                } else {
                    state.filterEquipments.append(equipment)
                }
                // Send filter results action
                return .send(.filterResults, animation: .default)
                
                // Handle toggling show only selected action
            case .toggleShowOnlySelected(let showOnlySelected):
                // Toggle show only selected flag
                state.showOnlySelected = showOnlySelected
                // Send filter results action
                return .send(.filterResults, animation: .default)
            }
        }
    }

}

struct ExerciseBluePrintsListView: View {
    @Bindable var store: StoreOf<ExerciseBluePrintsList>
    @FocusState var isSearchFieldFocused: Bool
    
    var body: some View {
        List {
            ScrollToView()
            
            // Recent section
            if store.recentResults.isNotEmpty && store.searchQuery.isEmpty && store.showOnlySelected.not() {
                Section("Recent") {
                    exerciseBluePrintList(bluePrints: store.recentResults)
                }.listSectionSeparator(.hidden)
            }
            
            // Exercises section
            Section("Exercises") {
                exerciseBluePrintList(bluePrints: store.displayResults)
            }
            .listSectionSeparator(.hidden)
            
            // Load more button
            // FIXME: loads everytime it appears
            if store.state.canFetchMore && !store.showOnlySelected {
                NextPageView {
                    store.send(.loadNextPage)
                }
                .previewBorder()
            }
        }
        .environment(\.defaultMinListRowHeight, 0)
        .previewBorder()
        .navigationTitle(store.showOnlySelected ? "Selected Exercises" : "All Exercises")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.automatic)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            // Search bar and filters
            VStack(spacing: .defaultVerticalSpacing) {
                Divider()
                
                HStack {
                    // Search bar
                    SearchBar(searchText: $store.searchQuery.sending(\.searchQueryChanged), prompt: "Search") {
                        hideKeyboard()
                    }
                    .focused($isSearchFieldFocused)
                    
                    Spacer()
                    
                    // Toggle selected vs all
                    // TODO: - Navigate to create new template (Backlog)
                    // MARK: - Toggle selected vs all
                    Button(action: {
                        store.send(.toggleShowOnlySelected(!store.showOnlySelected), animation: .default)
                    }, label: {
                        Label("Selected", systemImage: store.showOnlySelected ? "checklist.checked" : "checklist.unchecked")
                    })
                    
                    // Filter menu
                    // MARK: - Filter Menu
                    Button {
                        // Filter menu action
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle.fill")
                    }
                }
                .menuActionDismissBehavior(.disabled)
                .menuOrder(.fixed)
                .padding(.horizontal, .defaultHorizontalSpacing)
                .padding(.bottom, .defaultVerticalSpacing)
                .labelStyle(.iconOnly)
            }
            .background(.ultraThinMaterial)
            .foregroundStyle(.primary)
        }
        .overlay(alignment: .bottomTrailing) {
            // Add exercise button overlay
            if store.selectedBluePrints.isNotEmpty {
                Button(action: {
                    store.send(.finishButtonTapped)
                }, label: {
                    Text("^[Add \(store.selectedBluePrints.count) Exercise](inflect: true)")
                })
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .shadow(radius: 2)
                .padding(.horizontal, .defaultHorizontalSpacing)
                .padding(.bottom , .defaultVerticalSpacing)
                .safeAreaPadding(.bottom, .customTabBarHeight)
                .transition(.scale)
            }
        }
        .overlay {
            // Empty state view overlay
            // TODO: Add cases for show selected templates only
            if store.displayResults.isEmpty {
                if store.showOnlySelected {
                    EmptyStateView(title: "No Exercise selected", subtitle: "Select an exercise from the list.", resource: .placeholderSearch)
                } else if store.searchQuery.isNotEmpty {
                    EmptyStateView(title: "No Results for \"\(store.searchQuery)\"", subtitle: "Check the spelling or try a new search.", resource: .placeholderSearch)
                }
                // TODO: Loading state view should handle the else case
            }
        }
        .bind($store.isSearchFieldFocused, to: $isSearchFieldFocused) // Bind focus state
    }
    
    // Exercise blueprint list
    @ViewBuilder
    private func exerciseBluePrintList(bluePrints: [ExerciseBluePrint]) -> some View {
        // Iterate over each ExerciseBluePrint in the provided array
        ForEach(bluePrints) { bluePrint in
            // Check if the current ExerciseBluePrint is selected
            let isSelected = store.selectedBluePrints.contains(bluePrint)
            
            // Create a NavigationLink to the detailed view of the ExerciseBluePrint
            NavigationLink(
                state: WorkoutEditor.Path.State.exerciseDetails(
                    ExerciseBluePrintDetails.State(exercise: bluePrint)
                )
            ) {
                // Display the ExerciseBluePrintRowView with appropriate parameters
                ExerciseBluePrintRowView(
                    exercise: bluePrint,
                    isSelected: isSelected,
                    highlightText: store.searchQuery
                )
                // Handle tap gesture on the ExerciseBluePrintRowView
                .onTapGesture {
                    // Toggle selection state of the ExerciseBluePrint when tapped
                    if isSelected {
                        store.send(.deSelectTemplate(bluePrint), animation: .default)
                    } else {
                        store.send(.selectTemplate(bluePrint), animation: .default)
                    }
                }
            }
            // Customize list row appearance
            .listRowSeparator(.hidden, edges: .top) // Hide top separator
            .listRowBackground(isSelected ? Color.secondary.opacity(0.2) : Color.clear) // Set background color based on selection state
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16)) // Adjust insets
        }
    }
    
}

#Preview {
    ExerciseBluePrintsListView(store: StoreOf<ExerciseBluePrintsList>(initialState: ExerciseBluePrintsList.State(), reducer: {
        ExerciseBluePrintsList()
    }))
}
