//
//  DesignConstants.swift
//
//
//  Created by harsh vishwakarma on 14/12/23.
//

import SwiftUI

@MainActor
public extension CGFloat {
    static let listRowVerticalSpacing: CGFloat = 16
    static let listRowContentVerticalSpacing: CGFloat = 12
    static let listRowContentHorizontalSpacing: CGFloat = 16
    static let exerciseTemplatePreviewImageSize: CGFloat = 56.0
    static let exerciseTemplatePreviewImageCornerRadius: CGFloat = 16.0
    static let customTabBarHeight: CGFloat = 55.0
    static let sheetCornerRadius: CGFloat = 15.0
    static let InitialSheetDetentHeight: CGFloat = 110.0
}

@MainActor
public extension EdgeInsets {
    static let listRowInset = EdgeInsets(top: 0,
                                         leading: 0,
                                         bottom: 0,
                                         trailing: 0)
    static let listRowContentInset = EdgeInsets(top: .listRowContentVerticalSpacing,
                                                leading: .listRowContentHorizontalSpacing,
                                                bottom: .listRowContentVerticalSpacing,
                                                trailing: .listRowContentHorizontalSpacing)
    
    static let actionRowContentInset = EdgeInsets(
        top: 4,
        leading: 0,
        bottom: 4,
        trailing: 0)
}
