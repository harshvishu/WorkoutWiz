//
//  Item.swift
//  WorkoutWiz
//
//  Created by harsh vishwakarma on 06/11/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
