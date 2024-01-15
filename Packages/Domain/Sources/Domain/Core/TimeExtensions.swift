//
//  TimeExtensions.swift
//  
//
//  Created by harsh vishwakarma on 14/01/24.
//

import Foundation

extension TimeInterval {
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
}
