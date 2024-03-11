//
//  ViewExtensions.swift
//  ExpenseManager
//
//  Created by harsh vishwakarma on 22/07/23.
//

import SwiftUI
import Combine
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
    
    func printView(_ value: Any) -> Self {
        print(value)
        return self
    }
    
    func debugAction(_ closure: () -> Void) -> Self {
#if DEBUG
        closure()
#endif
        return self
    }
    
    @discardableResult
    func debugPrintView(_ value: Any) -> Self {
        debugAction { print(value) }
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
        
    @ViewBuilder
    func previewModifier<T: View>(_ modifier: (Self) -> T) -> some View {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            modifier(self)
        } else {
            self
        }
    }
    
    func previewBorder(_ color: Color = .red.opacity(0.25), width: CGFloat = 1) -> some View {
        previewModifier {
            $0.border(color, width: width)
        }
    }
    
    func previewBackground(_ color: Color = .red) -> some View {
        previewModifier {
            $0.background(color)
        }
    }
    
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
    @ViewBuilder
    func modifyIf<T: View>(_ bool: Bool, _ modifier: (Self) -> T) -> some View {
        if bool {
            modifier(self)
        } else {
            self
        }
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
    
    /// Usually you would pass  `@Environment(\.displayScale) var displayScale`
    @MainActor func render(scale displayScale: CGFloat = 1.0) -> UIImage? {
        let renderer = ImageRenderer(content: self)
        
        renderer.scale = displayScale
        
        return renderer.uiImage
    }
}

/// Custom TabView Modifiers
public extension View {
    @ViewBuilder
    func hideNativeTabBar() -> some View {
        self.toolbar(.hidden, for: .tabBar)
    }
}

public extension View {
    @ViewBuilder func tabSheet<SheetContent: View>(initialHeight: CGFloat = 100.0, sheetCornerRadius: CGFloat = 15.0, showSheet: Binding<Bool>, resizable: Binding<Bool>, detents: Set<PresentationDetent>, selectedDetent: Binding<PresentationDetent>, bottomPadding: CGFloat, @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        self
            .modifier(BottomSheetModifier(initialHeight: initialHeight, sheetCornerRadius: sheetCornerRadius, showSheet: showSheet, resizable: resizable, detents: detents, selectedDetent: selectedDetent, bottomPadding: bottomPadding, sheetView: content))
    }
}

/// Helper View Modifiers
fileprivate struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    
    @Binding private var showSheet: Bool
    @Binding private var resizable: Bool
    @Binding private var selectedDetent: PresentationDetent
    
    private var detents: Set<PresentationDetent>
    private var initialHeight: CGFloat
    private var sheetCornerRadius: CGFloat
    private var sheetView: SheetContent
    private var bottomPadding: CGFloat
    
    init(initialHeight: CGFloat, sheetCornerRadius: CGFloat, showSheet: Binding<Bool>, resizable: Binding<Bool>, detents: Set<PresentationDetent>, selectedDetent: Binding<PresentationDetent>, bottomPadding: CGFloat, sheetView: @escaping () -> SheetContent) {
        self.initialHeight = initialHeight
        self.sheetCornerRadius = sheetCornerRadius
        self._showSheet = showSheet
        self._resizable = resizable
        self.detents = detents
        self._selectedDetent = selectedDetent
        self.sheetView = sheetView()
        self.bottomPadding = bottomPadding
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSheet, content: {
                VStack(spacing: 0) {
                    sheetView
                    Divider()
                        .hidden()
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(height: bottomPadding)
                }
                .presentationDetents(resizable ? [.InitialSheetDetent, .ExpandedSheetDetent] : [.ExpandedSheetDetent], selection: $selectedDetent)
                .presentationCornerRadius(sheetCornerRadius)
                .presentationBackgroundInteraction(.enabled(upThrough: .ExpandedSheetDetent))
                .presentationBackground(.background)
                .interactiveDismissDisabled()
            })
    }
}

public extension PresentationDetent {
    static let InitialSheetDetent: PresentationDetent = .height(110.0)
    static let ExpandedSheetDetent: PresentationDetent = .fraction(0.99)
}

public enum PresentationDetentState {
    case collapsed
    case expanded
}

public extension PresentationDetent {
    var state: PresentationDetentState {
        isExpanded ? .expanded : .collapsed
    }
    
    var isExpanded: Bool {
        self == .ExpandedSheetDetent
    }
    
    var isCollapsed: Bool {
        !isExpanded
    }
    
    mutating func toggle() {
        self = isExpanded ? .InitialSheetDetent : .ExpandedSheetDetent
    }
}

/// Publisher to read keyboard changes.
public protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

public extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}

public extension View {
    /// Whether the view should be empty.
    /// - Parameter bool: Set to `true` to show the view (return EmptyView instead).
    func showIf(_ bool: Bool) -> some View {
        modifier(ConditionalView(show: [bool]))
    }
    
    /// returns a original view only if all conditions are true
    func showIf(_ conditions: Bool...) -> some View {
        modifier(ConditionalView(show: conditions))
    }
}

struct ConditionalView: ViewModifier {
    
    let show: [Bool]
    
    func body(content: Content) -> some View {
        Group {
            if show.first(where: { $0 == false }) == nil {
                content
            } else {
                EmptyView()
            }
        }
    }
}
