//
//  ExerciseRowHeaderView.swift
//  
//
//  Created by harsh vishwakarma on 20/01/24.
//

import Domain
import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import ComposableArchitecture

// Header View
struct ExerciseRowHeaderView: View {
    let store: StoreOf<ExerciseRow>
    
    @Binding var isExpanded: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            
//            Button(action: {
//                withAnimation {
//                    isExpanded.toggle()
//                }
//            }) {
//                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
//                    .frame(width: 25, height: 25)
//            }
//            .foregroundStyle(.tertiary)
//            .symbolVariant(.circle)
//            .contentTransition(.symbolEffect(.replace.downUp.byLayer))
//            .buttonStyle(.plain)
            
            Text(store.exercise.template?.name ?? "N/A")
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
            
            Button(action: {
                store.send(.delegate(.showBluePrintDetails), animation: .default)
            }, label: {
                Image(systemName: "info.circle.fill")
            })
            .buttonStyle(.plain)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: 25)
    }
}
