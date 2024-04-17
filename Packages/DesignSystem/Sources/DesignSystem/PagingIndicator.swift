//
//  PagingIndicator.swift
//
//
//  Created by harsh vishwakarma on 17/04/24.
//

import SwiftUI

public struct PagingIndicator: View {
    public init(
        activeTint: Color = .primary,
        inActiveTint: Color = .primary.opacity(0.15),
        opacityEffect: Bool = false,
        clipEdges: Bool = false
    ) {
        self.activeTint = activeTint
        self.inActiveTint = inActiveTint
        self.opacityEffect = opacityEffect
        self.clipEdges = clipEdges
    }
    
    var activeTint: Color = .primary
    var inActiveTint: Color = .primary.opacity(0.15)
    var opacityEffect: Bool = false
    var clipEdges: Bool = false
    
    public var body: some View {
        GeometryReader { geometry in
            if let scrollViewWidth = geometry.bounds(of: .scrollView(axis: .horizontal))?.width, scrollViewWidth > 0 {
                let minX = geometry.frame(in: .scrollView(axis: .horizontal)).minX
                let totalPages = Int(geometry.size.width / scrollViewWidth)
                
                // Calculate progress
                let freeProgress = -minX / scrollViewWidth
                let clippedProgress = min(max(freeProgress, 0.0), CGFloat(totalPages - 1))
                let progress = clipEdges ? clippedProgress : freeProgress
                
                // Calculate active and next indexes
                let activeIndex = Int(progress)
                let nextIndex = activeIndex + 1
                let indicatorProgress = progress - CGFloat(activeIndex)
                
                // Calculate indicator widths (Current & Next)
                let currentPageWidth = 18 - (indicatorProgress * 18)
                let nextPageWidth = indicatorProgress * 18
                
                // Create paging indicators
                HStack(spacing: 10) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        let isActive = activeIndex == index
                        let isNext = nextIndex == index
                        
                        Capsule()
                            .fill(Color.clear)
                            .frame(width: 8 + (isActive ? currentPageWidth : (isNext ? nextPageWidth : 0)), height: 8)
                            .overlay {
                                ZStack {
                                    Circle()
                                        .fill(inActiveTint)
                                    
                                    Capsule()
                                        .fill(activeTint)
                                        .opacity(opacityEffect ? (isActive ? 1 - indicatorProgress : (isNext ? indicatorProgress : 0)) : 1)
                                }
                            }
                    }
                }
                .frame(width: scrollViewWidth)
                .offset(x: -minX)
            }
        }
        .frame(height: 30)
    }
}

#Preview {
    ScrollView(.horizontal) {
        LazyHStack(alignment: .center, spacing: 0) {
            ForEach([Color.red, .green], id: \.self) {
                RoundedRectangle(cornerRadius: 15)
                    .fill($0)
                    .padding(.horizontal)
                    .containerRelativeFrame(.horizontal)
            }
        }
        .overlay(alignment: .bottom) {
            PagingIndicator(activeTint: .white, inActiveTint: .black, opacityEffect: false, clipEdges: true)
        }
    }
    .scrollIndicators(.hidden)
    .scrollTargetBehavior(.paging)
    .frame(height: 220)
}
