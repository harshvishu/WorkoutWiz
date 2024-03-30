//
//  ScrollToView.swift
//  
//
//  Created by harsh vishwakarma on 26/03/24.
//

import SwiftUI 

public struct ScrollToView: View {
    public enum Constants {
        public static let scrollToTop = "top"
    }
    
    public init() {}
    
    public var body: some View {
        HStack { EmptyView() }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(.init())
            .accessibilityHidden(true)
            .id(Constants.scrollToTop)
    }
}
