//
//  SwiftUIView.swift
//  FrameworksAndDrivers
//
//  Created by harsh vishwakarma on 26/07/24.
//

import SwiftUI
import TipKit

struct BodyWeightTip: Tip {
    var title: Text {
        Text("This exercise uses your body weight as the resistance.")
    }
    
    var message: Text? {
        Text("You can update your body weight from the settings tab.")
    }
    
    @Parameter
    static var showTip: Bool = false
    
//    var rules: [Rule] {
//        #Rule(Self.$showTip) {$0 == true}
//    }
    
//    var options: [any TipOption] {
//        return [
//            Tips.
//        ]
//    }
}
