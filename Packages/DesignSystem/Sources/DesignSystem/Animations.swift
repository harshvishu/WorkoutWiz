//
//  Animations.swift
//
//
//  Created by harsh vishwakarma on 21/02/24.
//

import SwiftUI

// MARK: - Animations

public extension Animation {
    static func customSpring() -> Animation {
        return Animation.spring(response: 0.3, dampingFraction: 0.3)
    }
    
    static func easeOut(duration: Double = 0.3) -> Animation {
        return Animation.timingCurve(0.17, 0.67, 0.83, 0.67, duration: duration)
    }
}

public func withCustomSpring<T>(_ action: @escaping () -> T) -> T {
    withAnimation(.customSpring(), action)
}

public func withEaseOut<T>(_ duration: Double = 0.3, _ action: @escaping () -> T) -> T {
    withAnimation(.easeOut(duration: duration), action)
}

public extension UIView {
    var allSubViews: [UIView] {
        subviews.flatMap { [$0] + $0.subviews }
    }
}


public extension View {
    func bipAnimation(trigger: Bool) -> some View {
        modifier(BipAnimation(trigger: trigger))
    }
}

struct BipAnimation: ViewModifier {
    
    var trigger: Bool
    @State var animate: Bool = true
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(animate ? 1.0 : 0.7)
            .onChange(of: trigger, { _, newValue in
                if newValue {
                    animate = false
                    withAnimation(.customSpring()) {
                        animate = true
                    }
                }
            })
    }
}

///The View to Animate
//Text(weight, format: .number.precision(.fractionLength(2)))
//    .font(.title.bold())
//    .bipAnimation(trigger: focusedField == .weight)
