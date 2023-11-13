//
//  Themes.swift
//  ExpenseManager
//
//  Created by Harsh on 25/07/23.
//

import SwiftUI
import Observation

public enum Theme: Int, Codable, CaseIterable, Hashable {
    case brocoli
    case earth
    case pumpkin
    case sunrize
    case blackAndWhite

    var name: String {
        ColorPalette(theme: self).name
    }
    
    var primaryColor: Color {
        ColorPalette(theme: self).primaryColor
    }
    var secondaryColor: Color {
        ColorPalette(theme: self).secondaryColor
    }
    
    var backgroundColor: Color {
        ColorPalette(theme: self).backgroundColor
    }
    
    var highlightColor: Color {
        ColorPalette(theme: self).highlightColor
    }
    
    var secondaryHighlightColor: Color {
        ColorPalette(theme: self).secondaryHighlightColor
    }
}

struct ColorPalette {
    var primaryColor: Color
    var secondaryColor: Color
    var backgroundColor: Color
    var highlightColor: Color
    var secondaryHighlightColor: Color
    var name: String
    
    init(theme: Theme) {
        
        primaryColor = .orange
        secondaryColor = .primary
        backgroundColor = .primary
        highlightColor = .primary
        secondaryHighlightColor = .primary
        name = "Test"
//        switch theme {
//        case .brocoli:
//            primaryColor = Color(.Theme.Brocoli.primary)
//            secondaryColor = Color(.Theme.Brocoli.secondary)
//            backgroundColor = Color(.Theme.Brocoli.background)
//            highlightColor = Color(.Theme.Brocoli.highlight)
//            secondaryHighlightColor = Color(.Theme.Brocoli.secondaryHighlight)
//            name = "Brocoli"
//        case .earth:
//            primaryColor = Color(.Theme.Earth.primary)
//            secondaryColor = Color(.Theme.Earth.secondary)
//            backgroundColor = Color(.Theme.Earth.background)
//            highlightColor = Color(.Theme.Earth.highlight)
//            secondaryHighlightColor = Color(.Theme.Earth.secondaryHighlight)
//            name = "Earth"
//        case .pumpkin:
//            primaryColor = Color(.Theme.Pumpkin.primary)
//            secondaryColor = Color(.Theme.Pumpkin.secondary)
//            backgroundColor = Color(.Theme.Pumpkin.background)
//            highlightColor = Color(.Theme.Pumpkin.highlight)
//            secondaryHighlightColor = Color(.Theme.Pumpkin.secondaryHighlight)
//            name = "Pumpkin"
//        case .sunrize:
//            primaryColor = Color(.Theme.Sunrize.primary)
//            secondaryColor = Color(.Theme.Sunrize.secondary)
//            backgroundColor = Color(.Theme.Sunrize.background)
//            highlightColor = Color(.Theme.Sunrize.highlight)
//            secondaryHighlightColor = Color(.Theme.Sunrize.secondaryHighlight)
//            name = "Sunrize"
//        case .blackAndWhite:
//            primaryColor = Color(.Theme.BlackAndWhite.primary)
//            secondaryColor = Color(.Theme.BlackAndWhite.secondary)
//            backgroundColor = Color(.Theme.BlackAndWhite.background)
//            highlightColor = Color(.Theme.BlackAndWhite.highlight)
//            secondaryHighlightColor = Color(.Theme.BlackAndWhite.secondaryHighlight)
//            name = "Black And White"
//        }
    }
}

extension Theme {
    static subscript(name: String) -> Theme? {
        return Theme.allCases.first { $0.name == name }
    }
}
