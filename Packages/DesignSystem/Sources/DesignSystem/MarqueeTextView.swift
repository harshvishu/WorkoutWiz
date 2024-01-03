//
//  MarqueeTextView.swift
//
//
//  Created by harsh vishwakarma on 01/01/24.
//

import SwiftUI

public struct MarqueeTextView : View {
    
    private let text: String
    private let font: UIFont
    private let separation: String
    private let scrollDurationFactor: CGFloat
    private let axes: Axis.Set
    
    @State private var animate = false
    @State private var size = CGSize.zero
    
    private var scrollDuration: CGFloat {
        stringWidth * scrollDurationFactor
    }
    
    private var stringWidth: CGFloat {
        (text + separation).widthOfString(usingFont: font)
    }
    
    private var stringHeight: CGFloat {
        (text + separation).heightOfString(usingFont: font)
    }
    
    private func shouldAnimated(_ width: CGFloat) -> Bool {
        width < stringWidth
    }
    
    static public let defaultSeparation = " "
    static public let defaultScrollDurationFactor: CGFloat = 0.02
    
    public init(
        _ text: String,
        font: UIFont = UIFont.preferredFont(forTextStyle: .body, compatibleWith: .current),
        separation: String = defaultSeparation,
        scrollDurationFactor: CGFloat = defaultScrollDurationFactor,
        axes: Axis.Set = .horizontal
    ){
        self.text = text
        self.font = font
        self.separation = separation
        self.scrollDurationFactor = scrollDurationFactor
        self.axes = axes
    }
    
    public init(
        _ text: String,
        textStyle: UIFont.TextStyle,
        separation: String = defaultSeparation,
        scrollDurationFactor: CGFloat = defaultScrollDurationFactor,
        axes: Axis.Set = .horizontal
    ){
        self.init(text, font: UIFont.preferredFont(forTextStyle: textStyle, compatibleWith: .current), separation: separation, scrollDurationFactor: scrollDurationFactor, axes: axes)
    }
    
    public var body : some View {
        
        GeometryReader { geometry in
            let shouldAnimated = shouldAnimated(geometry.size.width)
            
            scrollItem(offset: self.animate ? -getOffset() : .zero)
                .onAppear() {
                    size = geometry.size
                    if shouldAnimated  {
                        self.animate = true
                    }
                }
            
            if shouldAnimated{
                scrollItem(offset: self.animate ? .zero : getOffset())
            }
        }
    }
    
    private func scrollItem(offset: CGSize) -> some View {
        Text(text + separation)
            .lineLimit(1)
            .font(Font(uiFont: font))
            .offset(offset)
            .animation(Animation.linear(duration: scrollDuration).repeatForever(autoreverses: false), value: animate)
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxWidth: .infinity, alignment: .center)
        
    }
    private func getOffset() -> CGSize {
        CGSize(width: axes == .horizontal ? stringWidth : 0,
               height: axes == .vertical ? stringHeight : 0)
    }
}

private extension String {
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}

private extension Font {
    init(uiFont: UIFont) {
        self = Font(uiFont as CTFont)
    }
}

#Preview {
    MarqueeTextView("This is a test of scrolling text.  This is only a test.", textStyle: .body)
        .frame(height: 64)
}
