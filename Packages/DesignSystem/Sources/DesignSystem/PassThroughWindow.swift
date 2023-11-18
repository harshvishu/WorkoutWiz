//
//  File.swift
//  
//
//  Created by harsh vishwakarma on 18/11/23.
//

import UIKit

public final class PassThroughWindow: UIWindow {
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {return nil}
        return rootViewController?.view == view ? nil : view
    }
}
