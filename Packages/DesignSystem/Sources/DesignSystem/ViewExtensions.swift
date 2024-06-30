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

#if os(iOS)
public func hideKeyboard() {
    let resign = #selector(UIResponder.resignFirstResponder)
    UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
}
#endif

public extension View {
    
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
    
    func debugBorder(_ color: Color = .red.opacity(0.2), width: CGFloat = 1) -> some View {
        debugModifier {
            $0.border(color, width: width)
        }
    }
    
    func debugBackground(_ color: Color = .red.opacity(0.2)) -> some View {
        debugModifier {
            $0.background(color)
        }
    }
    
    func debugOverlay(_ color: Color = .red) -> some View {
        debugModifier {
            $0.overlay(Rectangle().fill(color).opacity(0.2))
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
            $0.background(color.opacity(0.2))
        }
    }
    
    
    func previewOverlay(_ color: Color = .red) -> some View {
        previewModifier {
            $0.overlay(Rectangle().fill(color).opacity(0.2))
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
    @ViewBuilder func tabSheet<SheetContent: View>(initialHeight: CGFloat = 100.0, sheetCornerRadius: CGFloat = 15.0, showSheet: Binding<Bool>, resizable: Binding<Bool>, states: Binding<Set<BottomSheetPresentationState>>, presentationState: Binding<BottomSheetPresentationState>, bottomPadding: CGFloat, @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        self
            .modifier(BottomSheetModifier(initialHeight: initialHeight, sheetCornerRadius: sheetCornerRadius, showSheet: showSheet, resizable: resizable, states: states, presentationState: presentationState, bottomPadding: bottomPadding, sheetView: content))
    }
}

/// Helper View Modifiers
fileprivate struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    
    @Binding private var showSheet: Bool
    @Binding private var resizable: Bool
    @Binding private var presentationState: BottomSheetPresentationState
    @Binding private var states: Set<BottomSheetPresentationState>
    
    private var initialHeight: CGFloat
    private var sheetCornerRadius: CGFloat
    private var sheetView: SheetContent
    private var bottomPadding: CGFloat
    
    init(initialHeight: CGFloat, sheetCornerRadius: CGFloat, showSheet: Binding<Bool>, resizable: Binding<Bool>, states: Binding<Set<BottomSheetPresentationState>>, presentationState: Binding<BottomSheetPresentationState>, bottomPadding: CGFloat, sheetView: @escaping () -> SheetContent) {
        self.initialHeight = initialHeight
        self.sheetCornerRadius = sheetCornerRadius
        self._showSheet = showSheet
        self._resizable = resizable
        self._states = states
        self._presentationState = presentationState
        self.sheetView = sheetView()
        self.bottomPadding = bottomPadding
    }
    
    func body(content: Content) -> some View {
        if showSheet {
            content.overlay {
                BottomSheetView(isPresented: $showSheet, resizable: $resizable, presentationState: $presentationState, initialHeight: initialHeight, sheetCornerRadius: sheetCornerRadius, bottomPadding: bottomPadding, states: $states, content: sheetView)
            }
        } else {
            content
        }
//        content
//            .sheet(isPresented: $showSheet) {
//                sheetView
//                    .padding(.bottom, bottomPadding)
//                    .presentationDetents(resizable ? [.InitialSheetDetent, .ExpandedSheetDetent] : [.ExpandedSheetDetent], selection: $selectedDetent)
//                    .presentationCornerRadius(sheetCornerRadius)
//                    .presentationBackgroundInteraction(.enabled(upThrough: .ExpandedSheetDetent))
//                    .presentationBackground(.background)
//                    .interactiveDismissDisabled()
//            }
    }
}

//public extension PresentationDetent {
//    static let InitialSheetDetent: PresentationDetent = .height(110.0)
//    static let ExpandedSheetDetent: PresentationDetent = .fraction(0.99)
//}

//public enum PresentationDetentState {
//    case collapsed
//    case expanded
//}

//public extension PresentationDetent {
//    var state: PresentationDetentState {
//        isExpanded ? .expanded : .collapsed
//    }
//    
//    var isExpanded: Bool {
//        self == .ExpandedSheetDetent
//    }
//    
//    var isCollapsed: Bool {
//        !isExpanded
//    }
//    
//    mutating func toggle() {
//        self = isExpanded ? .InitialSheetDetent : .ExpandedSheetDetent
//    }
//}

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


// MARK: - Empty State View
@ViewBuilder
public func EmptyStateView(title: String, subtitle: String, resource: ImageResource, imageWidth: CGFloat = 64) -> some View {
    GeometryReader { proxy in
        VStack(alignment: .center) {
            Image(resource)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: imageWidth)
            
            Group {
                Text(title)
                    .foregroundStyle(.primary)
                    .font(.headline)
                
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            .padding(.horizontal)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
        }
        .frame(width: proxy.size.width, alignment: .center)
        .frame(maxHeight: .infinity)
    }
}
