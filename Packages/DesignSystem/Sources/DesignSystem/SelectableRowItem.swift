//
//  SelectableRowItem.swift
//  
//
//  Created by harsh vishwakarma on 12/03/24.
//

import SwiftUI

public extension View {
    func selectableRow(isSelected: Bool, edge: HorizontalEdge = .trailing, alignment: VerticalAlignment = .center) -> some View {
        modifier(SelectableRowItem(isSelected: isSelected, edge: edge, alignment: alignment))
    }
}

struct SelectableRowItem: ViewModifier {
    var isSelected: Bool = false
    var edge: HorizontalEdge = .trailing
    var alignment: VerticalAlignment = .center
    
    func body(content: Content) -> some View {
        HStack(alignment: alignment) {
            if edge == .leading {
                image
            }
            
            content
                .layoutPriority(1)
            
            if edge == .trailing {
                image
            }
        }
        .previewBorder(Color.green.opacity(0.2))
    }
    
    private var image: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
            .contentTransition(.symbolEffect(.replace.byLayer.offUp))
            .symbolEffect(.bounce, value: isSelected)
            .foregroundStyle(isSelected ? Color.primary : Color.secondary)
            .layoutPriority(0)
            .previewBorder(Color.blue.opacity(0.2))
    }
}
