//
//  SizeClassAdaptiveView.swift
//  ExpenseManager
//
//  Created by harsh vishwakarma on 17/07/23.
//

import SwiftUI

public struct SizeClassAdaptiveView<Compact: View, Regular: View>: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif
    
    private var compact: Compact
    private var regular: Regular
    
    public init(
        @ViewBuilder compact: () -> Compact,
        @ViewBuilder regular: () -> Regular
    )
    {
        self.compact = compact()
        self.regular = regular()
    }
    
    public var body: some View {
#if os(iOS)
        if horizontalSizeClass == .regular
            || UIDevice.current.userInterfaceIdiom == .pad
            || UIDevice.current.userInterfaceIdiom == .mac
            || UIDevice.current.orientation.isLandscape
        {
            regular
        } else {
            compact
        }
        #else
        regular
        #endif
    }
}

@available(iOS 18.0, *)
#Preview {
    SizeClassAdaptiveView {
        Text("compact")
    } regular: {
        Text("regular")
    }
}
