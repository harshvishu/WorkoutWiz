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
    case counter(_ counter: Counter?, onNext: NextFieldHander? = nil, showPeriod: Bool)
    
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
        case .counter(let repCounter, let nextFieldHander, let showPeriod):
            self.customKeyboard(.counter(repCounter, onNext: nextFieldHander, showPeriod: showPeriod))
        }
    }
}

public typealias Counter = (Int) -> ()
public typealias NextFieldHander = () -> ()

fileprivate enum Key {
    case digit(Int)
    case period
    case submit
    case plus
    case minus
    case hideKeyboard
    case empty
    case delete
    case next
    
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
        case .next:
            "arrow.forward.square"
        case .delete:
            "delete.left.fill"
        }
    }
}

extension CustomKeyboard {
    static func counter(_ repCounter: Counter?, onNext nextFieldHandler: NextFieldHander? = nil, showPeriod: Bool = true) -> CustomKeyboard {
        CustomKeyboardBuilder { textDocumentProxy, submit, playSystemFeedback in
            let keys: [Key] = [.digit(1), .digit(2), .digit(3), .hideKeyboard,
                               .digit(4), .digit(5), .digit(6), .plus,
                               .digit(7), .digit(8), .digit(9), .minus,
                               (showPeriod ? .period : .empty), .digit(0), .delete, (nextFieldHandler != nil ? .next : .submit)]
            
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
                            return
                        case .period:
                            textDocumentProxy.insertText(".")
                        case .delete:
                            textDocumentProxy.deleteBackward()
                        case .minus:
                            repCounter?(-1)
                        case .plus:
                            repCounter?(1)
                        case .hideKeyboard, .submit:
                            submit?()
                        case .digit(let value):
                            textDocumentProxy.insertText("\(value)")
                        case .next:
                            nextFieldHandler?()
                        }
                        playSystemFeedback?()
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
