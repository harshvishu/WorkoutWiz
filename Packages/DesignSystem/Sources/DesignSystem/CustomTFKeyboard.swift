//
//  CustomTFKeyboard.swift
//
//
//  Created by harsh vishwakarma on 15/01/24.
//

import SwiftUI
import OSLog
import CustomKeyboardKit

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(#file)")

public enum CustomKeyboardType {
    case system(UIKeyboardType)
    case counter(_ counter: Counter?, showPeriod: Bool)
    
    func isCustom() -> Bool {
        if case .system = self {
            false
        } else {
            true
        }
    }
}

public extension TextField {
    @ViewBuilder
    func setKeyboard(_ keyboard: CustomKeyboardType) -> some View {
        switch keyboard {
        case .system(let type):
            self.keyboardType(type)
        case .counter(let repCounter, let showPeriod):
            self.customKeyboard(.counter(repCounter, showPeriod: showPeriod))
        }
    }
}

public typealias WeightChange = (Double) -> ()
public typealias Counter = (Int) -> ()
public typealias TimeCounter = (TimeInterval) -> ()

fileprivate enum Key {
    case digit(Int)
    case period
    case submit
    case plus
    case minus
    case hideKeyboard
    case empty
    case delete
    
    var sfSymbol: String {
        switch self {
        case .period:
            "P"
        case .empty:
            "E"
        case .digit(let value):
            "\(value)"
        case .hideKeyboard:
            "keyboard.chevron.compact.down"
        case .plus:
            "plus"
        case .minus:
            "minus"
        case .submit:
            "arrow.turn.down.left"
        case .delete:
            "delete.left"
        }
    }
}

extension CustomKeyboard {
    static func counter(_ repCounter: Counter?, showPeriod: Bool = true) -> CustomKeyboard {
        CustomKeyboardBuilder { textDocumentProxy, submit, playSystemFeedback in
            let keys: [Key] = [.digit(1), .digit(2), .digit(3), .hideKeyboard,
                               .digit(4), .digit(5), .digit(6), .plus,
                               .digit(7), .digit(8), .digit(9), .minus,
                               (showPeriod ? .period : .empty), .digit(0), .delete, .submit]
            
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(keys, id: \.sfSymbol) { k in
                    Button(action: {
                        switch k {
                        case .empty:
                            break
                        case .period:
                            textDocumentProxy.insertText(".")
                            playSystemFeedback?()
                        case .delete:
                            textDocumentProxy.deleteBackward()
                            playSystemFeedback?()
                        case .minus:
                            repCounter?(-1)
                            playSystemFeedback?()
                        case .plus:
                            repCounter?(1)
                            playSystemFeedback?()
                        case .hideKeyboard:
                            submit?()
                        case .submit:
                            submit?()
                            playSystemFeedback?()
                        case .digit(let value):
                            textDocumentProxy.insertText("\(value)")
                            playSystemFeedback?()
                        }
                    }, label: {
                        ZStack {
                            Color.clear
                            switch k {
                            case .period:
                                Text(".")
                            case .digit(let value):
                                Text("\(value)")
                            case .empty:
                                EmptyView()
                            default:
                                Image(systemName: k.sfSymbol)
                            }
                        }
                    })
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .foregroundStyle(.primary)
                    .buttonStyle(.borderless)
                }
            }
            .padding()
            .backgroundStyle(.windowBackground)
        }
    }
}

