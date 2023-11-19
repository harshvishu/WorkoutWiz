//
//  CustomTabBarView.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 18/11/23.
//

import SwiftUI

public struct CustomTabBar: View {
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
            .frame(height: 64)
        }
        .background(
            UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 15, bottomLeading: 0, bottomTrailing: 0, topTrailing: 15))
                .fill(.black)
                .ignoresSafeArea(.all)
        )
    }
}

#Preview {
    @State var selectedScreen: AppScreen = .dashboard
    @State var popToRootScreen: AppScreen = .other
    
    return CustomTabBar(selectedScreen: $selectedScreen, popToRootScreen: $popToRootScreen)
        .frame(maxHeight: .infinity, alignment: .bottom)
}
