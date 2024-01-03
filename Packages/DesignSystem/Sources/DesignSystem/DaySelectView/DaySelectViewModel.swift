//
//  DaySelectViewModel.swift
//  
//
//  Created by harsh on 16/09/22.
//

import SwiftUI

public final class DaySelectViewModel: ObservableObject {
    @Published var currentDayRange: [Day] = []
    @Published var today = Date()
    
    init() {
    }
    
    
    // FIXME: remove optional unwrapping
    func getToday() -> Day? {
        for day in currentDayRange {
            if day == today {
                return day
            }
        }
        return currentDayRange.first
    }
}
