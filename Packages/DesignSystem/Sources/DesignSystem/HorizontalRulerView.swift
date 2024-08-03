//
//  HorizontalRulerView.swift
//
//
//  Created by harsh vishwakarma on 10/05/24.
//

import Foundation
import SwiftUI

public struct HorizontalRulerView: View {
    
    private enum CancelID { case load }
    
    public init(config: Config, value: Binding<Double>) {
        self.config = config
        self._value = value
    }
    
    public let config: Config
    @Binding public var value: Double
    
    /// View Properties
    @State private var isLoaded: Bool = false
    
    public var body: some View {
        GeometryReader {
            let size = $0.size
            let horizontalPadding = size.width / 2
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: config.spacing) {
                    let totalSteps = config.steps * config.count
                    
                    ForEach(0...totalSteps, id: \.self) {index in
                        let remainder = index % config.steps
                        
                        Divider()
                            .background(remainder == 0 ? Color.primary : .gray)
                            .frame(height: remainder == 0 ? 20 : 10, alignment: .center)
                            .frame(maxHeight: 20, alignment: .bottom)
                            .overlay(alignment: .bottom) {
                                if remainder == 0 && config.showText {
                                    Text("\((index / config.steps) * config.multiplier)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .textScale(.secondary)
                                        .fixedSize()
                                        .offset(y: 20)
                                }
                            }
                    }
                }
                .frame(height: size.height)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: .init(get: {
                let position: Int? = isLoaded ? Int(value * CGFloat(config.steps)) / config.multiplier : nil
                return position
            }, set: { newValue in
                if let newValue {
                    withAnimation {
                        value = (CGFloat(newValue) / CGFloat(config.steps)) * CGFloat(config.multiplier)
                    }
                }
            }))
            .overlay(alignment: .center) {
                Rectangle()
                    .frame(width: 1, height: 40)
                    .padding(.bottom, 20)
            }
            .safeAreaPadding(.horizontal, horizontalPadding)
            .task(id: CancelID.load) {
                await setLoadWithDelay()
            }
        }
    }
    
    private func setLoadWithDelay() async {
        try? await Task.sleep(nanoseconds: 100_000_000)
        if !isLoaded {
            withAnimation {
                isLoaded = true
            }
        }
    }
    
    public struct Config {
        public init(count: Int, steps: Int = 10, spacing: CGFloat = 5.0, multiplier: Int = 10, showText: Bool = true) {
            self.count = count
            self.steps = steps
            self.spacing = spacing
            self.multiplier = multiplier
            self.showText = showText
        }
        
        var count: Int
        var steps: Int
        var spacing: CGFloat
        var multiplier: Int
        var showText: Bool
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable @State var value: Double = 0
    
    return VStack {
        Text("\(value)")
        
        HorizontalRulerView(config: .init(count: 10), value: $value)
            .frame(height: 60)
            .previewBorder()
    }
}
