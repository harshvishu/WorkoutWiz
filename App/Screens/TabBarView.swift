//
//  TabBarView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 17/11/23.
//

import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import UI

@MainActor
struct TabBarView: View {
    
    @Binding var selectedScreen: AppScreen
    @Binding var popToRootScreen: AppScreen
    
    @State private var listExersiceViewModel = ListExerciseViewModel(listExerciseUseCase: ListExerciseUseCase(exerciseRepository: SwiftDataExerciseRepository()))
    
    @State private var showSheet = false
    
    var body: some View {
        TabView(selection: .init(get: {
            selectedScreen
        }, set: { newTab in
            /// Stupid hack to trigger onChange binding in tab views.
            popToRootScreen = .other
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                popToRootScreen = selectedScreen
            }
            selectedScreen = newTab
        }), content:  {
            ForEach(AppScreen.availableTabs) { tab in
                tab.makeContentView(popToRootScreen: $popToRootScreen)
                    .hideNativeTabBar()
                    .tabItem {
                        tab.label
                    }
                    .tag(tab)
            }
        })
        .tabSheet(initialHeight: 116.0, sheetCornerRadius: 15.0, showSheet: $showSheet) {
            NavigationStack {
                ScrollView {
                    
                }
                .scrollIndicators(.hidden)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Text(selectedScreen.title)
                            .font(.title3.bold())
                    }
                    
                    if selectedScreen == .dashboard {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                RecordWorkoutView(viewModel: RecordWorkoutViewModel(recordWorkoutUseCase: RecordWorkoutUseCase(workoutRepository: FirebaseWorkoutRepository()), listExerciseUseCase: ListExerciseUseCase(exerciseRepository: SwiftDataExerciseRepository())), exerciseViewModel: listExersiceViewModel)
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                })
            }
        }
        .onChange(of: selectedScreen, { _, newValue in
            showSheet = newValue == .dashboard
        })
        .task {
            let tempScreen = selectedScreen
            selectedScreen = AppScreen.other
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                selectedScreen = tempScreen
            }
        }
    }
}

fileprivate struct RootView_Previews: PreviewProvider {
    @State static var selectedScreen: AppScreen = .dashboard
    @State static var popToRootScreen: AppScreen = .other
    
    static var previews: some View {
        RootView(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
    }
}
