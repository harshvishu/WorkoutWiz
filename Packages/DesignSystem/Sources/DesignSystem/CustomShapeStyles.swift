//
//  CustomShapeStyles.swift
//  
//
//  Created by harsh vishwakarma on 02/01/24.
//

import SwiftUI 

public struct PrimaryShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        HierarchicalShapeStyle.primary
    }
}

public struct BackgroundShapeStyle: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        BackgroundStyle.background
    }
}

//
//public extension ShapeStyle {
//    static var primaryLabel: any ShapeStyle { PrimaryShapeStyle() }
//    static var backgroundLabel: any ShapeStyle { BackgroundShapeStyle() }
//}
