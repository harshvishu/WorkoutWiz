//
//  DaySelectItemViewModel.swift
//  
//
//  Created by harsh on 16/09/22.
//

import SwiftUI

public final class DaySelectItemViewModel: ObservableObject {
    var day: Day
    var isSelected: Bool
    
    init(day: Day, isSelected: Bool) {
        self.day = day
        self.isSelected = isSelected
    }
    
    init(date: Date, isSelected: Bool) {
        self.day = Day(date: date)
        self.isSelected = isSelected
    }

    func extractDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: day.date)
    }
    
    func isToday() -> Bool {
        day == Date()
    }
}
