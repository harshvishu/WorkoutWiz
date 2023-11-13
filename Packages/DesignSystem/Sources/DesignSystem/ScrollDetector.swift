//
//  ScrollDetector.swift
//  ExpenseManager
//
//  Created by Harsh on 30/07/23.
//

import SwiftUI

public struct ScrollDetector: UIViewRepresentable {
    var onScroll: (CGFloat) -> ()
    var onDraggingEnd: (CGFloat, CGFloat) -> ()
    
    public func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            if let scrollView = uiView.superview?.superview?.superview as? UIScrollView, !context.coordinator.isDelegateAdded {
                scrollView.delegate = context.coordinator
                context.coordinator.isDelegateAdded = true
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {
        private var parent: ScrollDetector
        
        public init(parent: ScrollDetector) {
            self.parent = parent
        }
        
        public var isDelegateAdded: Bool = false
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.onScroll(scrollView.contentOffset.y)
        }
        
        public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            parent.onDraggingEnd(targetContentOffset.pointee.y, velocity.y)
        }
    }
}
