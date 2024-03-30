//
//  DesignConstants.swift
//
//
//  Created by harsh vishwakarma on 14/12/23.
//

import SwiftUI

@MainActor
public extension CGFloat {
    static let defaultVerticalSpacing: CGFloat = 12
    static let defaultHorizontalSpacing: CGFloat = 16
    static let exerciseTemplatePreviewImageSize: CGFloat = 56.0
    static let exerciseTemplatePreviewImageCornerRadius: CGFloat = 16.0
    static let customTabBarHeight: CGFloat = 55.0
    static let sheetCornerRadius: CGFloat = 15.0
    static let InitialSheetDetentHeight: CGFloat = 110.0
}

@MainActor
public extension EdgeInsets {
    static let listRowContentInset = EdgeInsets(top: .defaultVerticalSpacing,
                                                leading: .defaultHorizontalSpacing,
                                                bottom: .defaultVerticalSpacing,
                                                trailing: .defaultHorizontalSpacing)
    
    static let actionRowContentInset = EdgeInsets(
        top: 4,
        leading: 0,
        bottom: 4,
        trailing: 0)  
    
    static let buttonContentInsets = EdgeInsets(
        top: 8,
        leading: 16,
        bottom: 8,
        trailing: 16)
}
