//
//  OffsetObservingScrollView.swift
//  ExpenseManager
//
//  Created by Harsh on 07/08/23.
//

import SwiftUI

private enum ScrollOffsetNamespace {
    static let namespace = "scrollView"
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

private struct ScrollViewOffsetTracker: View {
    
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geo.frame(in: .named(ScrollOffsetNamespace.namespace)).origin
                )
        }
        .frame(height: 0)
    }
}

private extension ScrollView {
    
    func withOffsetTracking(
        action: @escaping (_ offset: CGPoint) -> Void
    ) -> some View {
        self.coordinateSpace(name: ScrollOffsetNamespace.namespace)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: action)
    }
}

public struct ScrollViewWithOffset<Content: View>: View {
    
    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        onScroll: ScrollAction? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onScroll = onScroll ?? { _ in }
        self.content = content
    }
    
    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let onScroll: ScrollAction
    private let content: () -> Content
    
    public typealias ScrollAction = (_ offset: CGPoint) -> Void
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            ZStack(alignment: .top) {
                ScrollViewOffsetTracker()
                content()
                    .scrollTargetLayout()
            }
        }.withOffsetTracking(action: onScroll)
    }
}

// Stretchable header

private extension View {
    
    @ViewBuilder
    func stretchable(in geo: GeometryProxy, sticky: Bool = true, minHeight: CGFloat = 0) -> some View {
        let width = geo.size.width
        let height = geo.size.height
        let minY = geo.frame(in: .global).minY
        let useStandard = minY <= 0
        let finalHeight = sticky ? ((height + minY) < minHeight ? (minHeight) : (height + minY)) : (height + (useStandard ? 0 : minY))
        let finalOffset = sticky ? (-minY) : (useStandard ? 0 : -minY)
        self.frame(width: width, height: finalHeight, alignment: .bottom)
            .offset(y: finalOffset)
    }
}

public struct ScrollViewHeader<Content: View>: View {
    
    public init(
        headerMinHeight: CGFloat,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.headerMinHeight = headerMinHeight
        self.content = content
    }
    
    private let headerMinHeight: CGFloat
    private let content: () -> Content
    
    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let minY = geo.frame(in: .global).minY
            let finalHeight = (height + minY) < headerMinHeight ? (headerMinHeight) : (height + minY)
            
            content()
                .frame(width: width, height: finalHeight, alignment: .bottom)
                .offset(y: -minY)
        }
    }
}

public struct ScrollViewWithStickyHeader<Header: View, Content: View>: View {
    
    public init(
        _ axes: Axis.Set = .vertical,
        @ViewBuilder header: @escaping () -> Header,
        headerHeight: CGFloat,
        headerMinHeight: CGFloat? = nil,
        showsIndicators: Bool = true,
        size: CGSize,
        safeArea: EdgeInsets,
        onScroll: ScrollAction? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.header = header
        self.headerHeight = headerHeight
        self.headerMinHeight = headerMinHeight
        self.size = size
        self.safeArea = safeArea
        self.onScroll = onScroll
        self.content = content
    }
    
    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let header: () -> Header
    private let headerHeight: CGFloat
    private let headerMinHeight: CGFloat?
    private let onScroll: ScrollAction?
    private let content: () -> Content
    
    private let size: CGSize
    private let safeArea: EdgeInsets
    
    
    public typealias ScrollAction = (_ offset: CGPoint, _ headerVisibleRatio: CGFloat) -> Void
    
    @State
    private var scrollOffset: CGPoint = .zero
    
    private var headerVisibleRatio: CGFloat {
        max(0, (headerHeight + scrollOffset.y) / headerHeight)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            scrollView
        }
        .prefersNavigationBarHidden()
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

private extension ScrollViewWithStickyHeader {
    
    var scrollView: some View {
        GeometryReader { proxy in
            ScrollViewWithOffset(onScroll: handleScrollOffset) {
                VStack(spacing: 0) {
                    scrollHeader
                    content()
                }
            }
        }
    }
    
    var scrollHeader: some View {
        ScrollViewHeader(headerMinHeight: headerMinHeight ?? 0.0, content: header)
        .zIndex(1000)
        .frame(height: headerHeight)
    }
    
    func handleScrollOffset(_ offset: CGPoint) {
        self.scrollOffset = offset
        self.onScroll?(offset, headerVisibleRatio)
    }
    
    var rotationDegrees: CGFloat {
        guard headerVisibleRatio > 1 else { return 0 }
        let value = 20.0 * (1 - headerVisibleRatio)
        return min(max(value, -5.0), 0.0)
    }
    
    var verticalOffset: CGFloat {
        guard headerVisibleRatio < 1 else { return 0 }
        return 70.0 * (1 - headerVisibleRatio)
    }
}

private extension View {
    
    @ViewBuilder
    func prefersNavigationBarHidden() -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 16.0, macOS 13.0, *) {
            self.toolbarBackground(.hidden)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
