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

public let appBackgroundColor = Color("background", bundle: uiBundle)
public let appAccentColor = Color("accent", bundle: uiBundle)

struct Logger {
    static let ui = os.Logger(subsystem: uiBundle.bundleIdentifier!, category: "UI/View")
    static let state = os.Logger(subsystem: uiBundle.bundleIdentifier!, category: "UI/State")
    static let action = os.Logger(subsystem: uiBundle.bundleIdentifier!, category: "UI/Action")
}
