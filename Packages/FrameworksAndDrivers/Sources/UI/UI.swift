//
//  UI.swift
//
//
//  Created by harsh vishwakarma on 20/12/23.
//

import Foundation
import SwiftUI
import OSLog

public let uiBundle = Bundle.module

// Shared UserDefaults suite name using the App Group identifier
let suiteName = "group." + (Bundle.main.bundleIdentifier ?? "") + ".SharedStorage"
let sharedDefaults = UserDefaults(suiteName: suiteName) ?? .standard

struct Logger {
    static let ui = os.Logger(subsystem: uiBundle.bundleIdentifier!, category: "UI/View")
    static let state = os.Logger(subsystem: uiBundle.bundleIdentifier!, category: "UI/State")
    static let action = os.Logger(subsystem: uiBundle.bundleIdentifier!, category: "UI/Action")
}

// MARK: Logger extensions
extension Logger {
    static func logDebug(_ object: Any) {
        dump(object)
    }
}
