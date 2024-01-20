//
//  RowHeaderView.swift
//  
//
//  Created by harsh vishwakarma on 20/01/24.
//

import Domain
import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import OSLog

// Header View
struct RowHeaderView: View {
    
    var editWorkoutViewModel: WorkoutEditorViewModel
    
    @Binding var exercise: ExerciseRecord
    @Binding var isExpanded: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            }
            .foregroundStyle(.tertiary)
            .symbolVariant(.circle)
            .contentTransition(.symbolEffect(.replace.downUp.byLayer))
            .buttonStyle(.plain)
            
            Text(exercise.template.name)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: {
                Swift.print("Info Button tapped")
            }, label: {
                Image(systemName: "info.circle.fill")
            })
            .buttonStyle(.plain)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: 24)
    }
}
