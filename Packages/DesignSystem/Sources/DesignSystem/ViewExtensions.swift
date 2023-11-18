//
//  ViewExtensions.swift
//  ExpenseManager
//
//  Created by harsh vishwakarma on 22/07/23.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DesignSystem", category: "ViewExtension")

public extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
    
    func print(_ value: Any) -> Self {
        Swift.print(value)
        return self
    }
    
    func debugAction(_ closure: () -> Void) -> Self {
        #if DEBUG
        closure()
        #endif
        return self
    }
    
    @discardableResult
    func debugPrint(_ value: Any) -> Self {
        debugAction { _ = print(value) }
    }
    
    func debugModifier<T: View>(_ modifier: (Self) -> T) -> some View {
        #if DEBUG
        return modifier(self)
        #else
        return self
        #endif
    }
    
    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        debugModifier {
            $0.border(color, width: width)
        }
    }
    
    func debugBackground(_ color: Color = .red) -> some View {
        debugModifier {
            $0.background(color)
        }
    }
    
    func eraseToAnyView() -> AnyView {
      AnyView(self)
    }
}

public extension CGSize {
    var max: CGFloat {
        Swift.max(self.width, self.height)
    }
    
    var min: CGFloat {
        Swift.min(self.width, self.height)
    }
}

#if os(iOS)
let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height


public func minOfHeightOrWidth() -> CGFloat {
    min(SCREEN_WIDTH, SCREEN_HEIGHT)
}
#endif

// Dynamic Size Calculation
public struct SizePreferenceKey: PreferenceKey {
    public static var defaultValue: CGSize = .zero
    
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

public extension View {
    func measureSize(size: Binding<CGSize>) -> some View {
        self.background(GeometryReader { geometry in
            Color.clear
                .preference(key: SizePreferenceKey.self, value: geometry.size)
                .onAppear {
                    size.wrappedValue = geometry.size
                }
        })
    }
}

/// Custom TabView Modifiers
public extension View {
    @ViewBuilder
    func hideNativeTabBar() -> some View {
        self.toolbar(.hidden, for: .tabBar)
    }
}


public extension TabView {
    @ViewBuilder
    func tabSheet<SheetContent: View>(initialHeight: CGFloat = 100.0, sheetCornerRadius: CGFloat = 15.0, showSheet: Binding<Bool>, @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        self
            .modifier(BottomSheetModifier(initialHeight: initialHeight, sheetCornerRadius: sheetCornerRadius, showSheet: showSheet, sheetView: content()))
    }
}

/// Helper View Modifiers
fileprivate struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    var initialHeight: CGFloat
    var sheetCornerRadius: CGFloat
    @Binding var showSheet: Bool        // View Property
    var sheetView: SheetContent
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSheet, content: {
                sheetView
                    .presentationDetents([.height(initialHeight), .medium, .fraction(0.99)])
                    .presentationCornerRadius(sheetCornerRadius)
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .presentationBackground(.regularMaterial)
                    .interactiveDismissDisabled()
            })
    }
}
