//
//  KeyboardOberver.swift
//
//
//  Created by harsh vishwakarma on 07/01/24.
//

import Foundation
import Combine
import SwiftUI
import OSLog

public extension View {
    /// @Environment(\.keyboardShowing) var keyboardShowing
    func addKeyboardVisibilityToEnvironment() -> some View {
        modifier(KeyboardVisibility())
    }
}

private struct KeyboardShowingEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    var keyboardShowing: Bool {
        get { self[KeyboardShowingEnvironmentKey.self] }
        set { self[KeyboardShowingEnvironmentKey.self] = newValue }
    }
}

private struct KeyboardVisibility: ViewModifier {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: KeyboardVisibility.self))
#if os(macOS)
    
    fileprivate func body(content: Content) -> some View {
        content
            .environment(\.keyboardShowing, false)
    }
    
#else
    
    @State var isKeyboardShowing: Bool = false
    
    fileprivate func body(content: Content) -> some View {
        content
            .environment(\.keyboardShowing, isKeyboardShowing)
            .task {
                for await _ in NotificationCenter.default.notifications(named: UIResponder.keyboardWillShowNotification) {
                    isKeyboardShowing =  true
                    logger.info("set isKeyboardShowing : \(isKeyboardShowing)")
                }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: UIResponder.keyboardWillHideNotification) {
                    isKeyboardShowing =  false
                    logger.info("set isKeyboardShowing : \(isKeyboardShowing)")
                }
            }
    }
    
#endif
}

extension Notification: @unchecked Sendable { }
