//
//  ExerciseRepRowView.swift
//
//
//  Created by harsh vishwakarma on 01/02/24.
//

import Domain
import SwiftUI
import DesignSystem
import ApplicationServices
import Persistence
import Combine
import OSLog


struct ExerciseRepRowView: View {
    
    enum Field: Hashable {
        case durationField
        case repField
        case weightField
    }
    
    var set: Rep
    var position: Int
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 4) {
            
            Image(systemName: set.repType == .none ? "\(position + 1).circle" : set.repType.sfSymbol)
                .foregroundStyle(set.repType.color)
                .frame(width: 25, height: 25)
                .transition(.opacity)
                .animation(.customSpring(), value: set.repType)
            
            switch set.countUnit {
            case .time:
                HStack(alignment: .top) {
                    
                    let elapsedTime = set.time.elapsedTime
                    
                    Text(elapsedTime.formattedString)
                        .font(.title.bold())
                    
//                    Text(elapsedTime.formattedTimeNotation)
//                        .font(.caption2)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                
            case .rep:
                HStack(alignment: .top) {
                    Text(set.count, format: .number)
                        .font(.title.bold())
                    
//                    Text("\(set.countUnit.description)")
//                        .font(.caption2)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            
            Text("x")
                .font(.caption2)
                .foregroundStyle(.primary)
            
            HStack(alignment: .top) {
                Text(set.weight, format: .number.precision(.fractionLength(2)))
                    .font(.title.bold())
                
//                Text("\(set.weightUnit.sfSymbol)")
//                    .font(.caption2)
            }
            .lineLimit(1)
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
