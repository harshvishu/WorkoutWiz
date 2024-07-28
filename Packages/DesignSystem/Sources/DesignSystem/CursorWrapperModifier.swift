//
//  CursorWrapperModifier.swift
//  
//
//  Created by harsh vishwakarma on 17/02/24.
//

import SwiftUI 

public struct CursorWrapperModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
    }
}


struct TextFieldAppearance: ViewModifier {
    
    public var cornerRadius: CGFloat
    public var isSelected: Bool
    
    public func body(content: Content) -> some View {
        content
            .modifyIf(isSelected) {
                $0.background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.clear)
                        .stroke(.primary, lineWidth: 0.5)
                        .background(.quinary.opacity(0.5))
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .contentShape(Rectangle())
            }
        // TODO: see for animations
//            .animation(.customSpring(), value: isSelected)
//            .transition(.scale(scale: 0.1, anchor: .center))
    }
}

public extension View {
    func textFieldAppearance(cornerRadius: CGFloat = 16, isSelected: Bool) -> some View {
        modifier(TextFieldAppearance(cornerRadius: cornerRadius, isSelected: isSelected))
    }
}

@available(iOS 18.0, *)
#Preview {
    return Text("1234")
        .frame(maxWidth: .infinity)
        .textFieldAppearance(cornerRadius: 16, isSelected: false)
}
