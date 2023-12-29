//
//  CustomTabBarView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 18/11/23.
//

import SwiftUI
import DesignSystem

public struct CustomTabBar: View, KeyboardReadable {
    @Environment(WorkoutWizAppModel.self) var workoutWizAppModel
    
    @Binding var selectedScreen: AppScreen
    @Binding var popToRootScreen: AppScreen
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(AppScreen.availableTabs) { tab in
                    Button( action: {
                        popToRootScreen = .other
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            popToRootScreen = selectedScreen
                        }
                        selectedScreen = tab
                    }, label: {
                        VStack {
                            tab.image
                                .font(.title2)
                            Text(tab.title)
                                .font(.caption)
                        }
                        .foregroundStyle(selectedScreen == tab ? .white : .gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(.rect)
                    })
                }
            }
            .frame(height: 55)
        }
        .background(
            UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 15, bottomLeading: 0, bottomTrailing: 0, topTrailing: 15))
                .fill(.black)
                .ignoresSafeArea(.all)
        )
        .opacity(workoutWizAppModel.showTabBar ? 1 : 0)
        .onReceive(keyboardPublisher) { isKeyboardVisible in
            workoutWizAppModel.showTabBar = !isKeyboardVisible
        }
    }
}

#Preview {
    @State var selectedScreen: AppScreen = .dashboard
    @State var popToRootScreen: AppScreen = .other
    
    return CustomTabBar(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
        .environment(WorkoutWizAppModel())
        .frame(maxHeight: .infinity, alignment: .bottom)
}
