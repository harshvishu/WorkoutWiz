//
//  DashboardTab.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 17/11/23.
//

import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence

@MainActor
public struct DashboardScreen: View {
    @State private var listExersiceViewModel = ListExerciseViewModel(listExerciseUseCase: ListExerciseUseCase(exerciseRepository: SwiftDataExerciseRepository()))
    
    @State private var routerPath = RouterPath()
    @Binding var popToRootScreen: AppScreen
    
    init(popToRootScreen: Binding<AppScreen>) {
        _popToRootScreen = popToRootScreen
    }
    
    public var body: some View {
        NavigationStack {
            ListExerciseView(viewModel: listExersiceViewModel)
                .withAppRouter()
                .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
        }
    }
}

#Preview {
    @State var popToRootScreen: AppScreen = .other
    
    return DashboardScreen(popToRootScreen: $popToRootScreen)
}
