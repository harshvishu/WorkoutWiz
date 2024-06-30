//
//  BottomSheetView.swift
//
//
//  Created by harsh vishwakarma on 27/06/24.
//

import SwiftUI
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DesignSystem", category: "BottomSheetView")

public struct BottomSheetView<SheetContent: View>: View {
    @Binding private var isPresented: Bool
    @Binding private var resizable: Bool
    @Binding public var presentationState: BottomSheetPresentationState
    @Binding public var states: Set<BottomSheetPresentationState>
    
    public var initialHeight: CGFloat
    public var sheetCornerRadius: CGFloat
    public var bottomPadding: CGFloat
    public var content: SheetContent
    
    @State private var translation: CGSize = .zero
    @State private var offsetY: CGFloat = .zero
    
    private var dragIndicatorHeight = CGFloat(32)
    private var contentSpacing = CGFloat(8)
    
    init (isPresented: Binding<Bool>, resizable: Binding<Bool>, presentationState: Binding<BottomSheetPresentationState>, initialHeight: CGFloat, sheetCornerRadius: CGFloat, bottomPadding: CGFloat, states: Binding<Set<BottomSheetPresentationState>>, content: SheetContent) {
        _isPresented = isPresented
        _resizable = resizable
        _presentationState = presentationState
        _states = states
        self.initialHeight = initialHeight
        self.sheetCornerRadius = sheetCornerRadius
        self.bottomPadding = bottomPadding
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: 0) {
                // Drag indicator
                Capsule(style: .continuous)
                    .fill(.tertiary)
                    .frame(width: dragIndicatorHeight, height: 4)
                    .padding(.vertical, contentSpacing)
                
                // MARK: Content
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .background(.background)
            .animation(.easeInOut, value: isPresented)
            .mask(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .shadow(radius: 1)
            .ignoresSafeArea(edges: .bottom)
            .offset(y: translation.height + offsetY)
            .gesture(DragGesture()
                .onChanged{ value in
                    translation = value.translation
                    
                    logger.debug("MoveY : \(translation.height)")
                    
                }.onEnded { value in
                    let snap = translation.height
                    logger.debug("snap: \(snap)")
                    
                    guard resizable else {
                        withAnimation(.interactiveSpring()) {
                            translation = .zero
                        }
                        return
                    }
                    
                    if snap > 100 && states.contains(.collapsed) {
                        presentationState = .collapsed
                    } else if snap < -100 && states.contains(.expanded) {
                        presentationState = .expanded
                    } else {
                        withAnimation(.interactiveSpring()) {
                            translation = .zero
                        }
                    }
                }
            )
            .onChange(of: presentationState, initial: true) { _, newValue in
                withAnimation(.interactiveSpring()) {
                    onStateChange(proxy: proxy)
                }
            }
        }
    }
    
    private func onStateChange(proxy: GeometryProxy) {
        let height = proxy.size.height
        
        switch presentationState {
            case .collapsed:
                offsetY = height - (initialHeight + 2 * contentSpacing )
            case .expanded:
                offsetY = .zero
        }
        translation = .zero
    }
}

public enum BottomSheetPresentationState: Int, Equatable {
    case collapsed
    case expanded
    
    public var isExpanded: Bool {
        self == .expanded
    }
    
    public var isCollapsed: Bool {
        !isExpanded
    }
    
    public mutating func toggle() {
        self = isExpanded ? .collapsed : .expanded
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable @State var isPresented: Bool = true
    @Previewable @State var resizable: Bool = true
    @Previewable @State var selectedDetent: BottomSheetPresentationState = .expanded
    @Previewable @State var states: Set<BottomSheetPresentationState> = [.expanded, .collapsed]

    BottomSheetView<Color>(isPresented: $isPresented, resizable: $resizable, presentationState: $selectedDetent, initialHeight: 100, sheetCornerRadius: 20, bottomPadding: 50, states: $states, content: Color.red.opacity(0.3))
}
