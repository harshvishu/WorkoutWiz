//
//  TimeExtensions.swift
//  
//
//  Created by harsh vishwakarma on 14/01/24.
//

import Foundation

public extension TimeInterval {
    var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    var seconds: Int {
        return Int(self) % 60
    }
    
    var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    var hours: Int {
        return Int(self) / 3600
    }
    
    var elapsedTime: ElapsedTime {
        ElapsedTime(timeInterval: self)
    }
    
    func formattedElapsedTime(formatter: DateComponentsFormatter? = nil, short: Bool = false) -> String {
        let formatter = formatter ?? getDateComponentsFormatter(self, short: short)
        return formatter.string(from: self) ?? ""
    }
    
    func formattedElapsedTime(
        allowedUnits: NSCalendar.Unit,
        unitsStyle: DateComponentsFormatter.UnitsStyle
    ) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.unitsStyle = unitsStyle
        return formatter.string(from: self) ?? self.formatted()
    }
}

// TODO: Needs improvement
public struct ElapsedTime {
    public private(set) var hours: Int
    public private(set) var minutes: Int
    public private(set) var seconds: Int
    public private(set) var milliseconds: Int
    
    public private(set) var formattedString: String
    public private(set) var formattedTimeNotation: String
    
    public init(timeInterval: TimeInterval) {
        let totalMilliseconds = Int(timeInterval * 1000)
        
        // Calculate hours
        self.hours = totalMilliseconds / (1000 * 60 * 60)
        
        // Calculate remaining minutes
        let remainingMillisecondsInHour = totalMilliseconds % (1000 * 60 * 60)
        self.minutes = remainingMillisecondsInHour / (1000 * 60)
        
        // Calculate remaining seconds
        let remainingMillisecondsInMinute = totalMilliseconds % (1000 * 60)
        self.seconds = remainingMillisecondsInMinute / 1000
        
        // Calculate remaining milliseconds
        self.milliseconds = (totalMilliseconds % 1000) / 100
        
        self.formattedString =  timeInterval.formattedElapsedTime()
        
        if timeInterval > 3600 {
            formattedTimeNotation = "hrs"
        } else if timeInterval > 60 {
            formattedTimeNotation = "min"
        } else {
            formattedTimeNotation = "sec"
        }
    }  
    
    public init(timeInSeconds: Int) {
        self.init(timeInterval: TimeInterval(timeInSeconds))
    }
}
