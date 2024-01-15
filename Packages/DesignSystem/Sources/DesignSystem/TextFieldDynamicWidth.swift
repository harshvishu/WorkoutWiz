//
//  TextFieldDynamicWidth.swift
//  
//
//  Created by harsh vishwakarma on 14/01/24.
//

import SwiftUI

public struct TextFieldDynamicWidth: View {
    public init(title: String, onEditingChanged: @escaping (Bool) -> Void, onCommit: @escaping () -> Void, text: Binding<String>) {
        self.title = title
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self._text = text
    }
    
    public let title: String
    public let onEditingChanged: (Bool) -> Void
    public let onCommit: () -> Void

    @Binding public var text: String
    
    @State private var textRect = CGRect()
    
    public var body: some View {
        ZStack {
            Text(text == "" ? title : text).background(GlobalGeometryGetter(rect: $textRect)).layoutPriority(1).opacity(0)
            HStack {
                TextField(title, text: $text, onEditingChanged: onEditingChanged, onCommit: onCommit)
                .frame(width: textRect.width)
            }
        }
    }
}


//
//  GlobalGeometryGetter
//
// source: https://stackoverflow.com/a/56729880/3902590
//

struct GlobalGeometryGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }
    
    @MainActor
    func makeView(geometry: GeometryProxy) -> some View {
                DispatchQueue.main.async {
        self.rect = geometry.frame(in: .global)
                }
        return Rectangle().fill(Color.clear)
    }
}

