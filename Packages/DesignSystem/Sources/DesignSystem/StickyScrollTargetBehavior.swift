//
//  StickyScrollTargetBehavior.swift
//  ExpenseManager
//
//  Created by Harsh on 07/08/23.
//

import SwiftUI

public struct StickyScrollTargetBehavior: ScrollTargetBehavior {
    public var onDraggingEnd: (CGFloat, CGFloat) -> ()
    
    public func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let offset = target.rect.origin.y
        let velocity = context.velocity.dy
        
        onDraggingEnd(offset, velocity)
    }
}
