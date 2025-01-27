//
//  CustomKeyboard.swift
//
//
//  Created by harsh vishwakarma on 15/01/24.
//

import SwiftUI
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(#file)")

public typealias Counter = (Int) -> ()
public typealias NextFieldHander = () -> ()
public typealias KeyInputValidaton = (UITextDocumentProxy, CustomKey) -> (Bool)

public enum CustomKey: Equatable {
    case digit(Int)
    case period
    case submit
    case plus
    case minus
    case hideKeyboard
    case empty
    case delete
    case next
    case prev
    case undo
    case switchTime
    case switchRep
    
    public var sfSymbol: String {
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
            "arrow.forward"
        case .prev:
            "arrow.backward"
        case .delete:
            "delete.left.fill"
        case .undo:
            "arrow.uturn.backward"
        case .switchRep:
            "123.rectangle.fill"
        case .switchTime:
            "timer"
        }
    }
    
    @ViewBuilder
    public var view: some View {
        switch self {
        case .period:
            Text(".")
        case .digit(let value):
            Text("\(value)")
        case .submit:
            Text("Done")
        case .next:
            Text("next")
        case .empty:
            EmptyView()
        default:
            Image(systemName: sfSymbol)
        }
    }
    
    public func buttonStyle() -> any PrimitiveButtonStyle {
        switch self {
        case .empty:
            PlainButtonStyle()
        case .submit:
            BorderedProminentButtonStyle()
        default:
            BorderedButtonStyle()
        }
    }
}

public typealias KeyPressHandler = (CustomKey) -> ()
public typealias TimeChangeHandler = (TimeInterval) -> ()

public enum RepInputMode {
    case repCount
    case repCountWithoutWeight
    case timeCount
    case weight
}

public struct RepInputKeyboard: View {
    
    @State private var timePickerModel = TimerPickerModel()

    private var mode: RepInputMode
    private var keyPressHandler : KeyPressHandler?
    private var timeChangeHandler : TimeChangeHandler?
    
    public init(
        mode: RepInputMode,
        keyPressHandler: KeyPressHandler? = nil,
        timeChangeHandler: TimeChangeHandler? = nil
    ) {
        self.mode = mode
        self.keyPressHandler = keyPressHandler
        self.timeChangeHandler = timeChangeHandler
    }
    
    public var body: some View {
        Group {
            switch mode {
                case .repCount, .repCountWithoutWeight, .weight:
                keypadInputView
            case .timeCount:
                wheelInputView
                    .onChange(of: timePickerModel.totalTimeForCurrentSelection, { oldValue, newValue in
                        timeChangeHandler?(TimeInterval(newValue))
                    })
            }
        }
        // Disabling the unwanted animations
        .transaction { transaction in
            transaction.animation = nil
        }
        .foregroundStyle(.primary)
        .frame(maxHeight: 240)
        .padding([.leading, .bottom, .trailing])
    }
    
    private var keysSet: [CustomKey] {
        switch mode {
            case .repCountWithoutWeight:
                [.digit(1), .digit(2), .digit(3), .switchTime,
                 .digit(4), .digit(5), .digit(6), .plus,
                 .digit(7), .digit(8), .digit(9), .minus,
                 .empty, .digit(0), .delete, .submit]
        case .repCount:
            [.digit(1), .digit(2), .digit(3), .switchTime,
             .digit(4), .digit(5), .digit(6), .plus,
             .digit(7), .digit(8), .digit(9), .minus,
             .empty, .digit(0), .delete, .next]
        case .timeCount:
            []
        case .weight:
            [.digit(1), .digit(2), .digit(3), .empty,
             .digit(4), .digit(5), .digit(6), .plus,
             .digit(7), .digit(8), .digit(9), .minus,
             .period, .digit(0), .delete, .submit]
        }
    }
    
    @ViewBuilder
    var keypadInputView: some View {
        let keys: [CustomKey] = keysSet
        
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        // TODO: Play feedback
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(keys, id: \.sfSymbol) { k in
                Button(action: {
                    keyPressHandler?(k)
                }, label: {
                    ZStack {
                        Color.clear
                        k.view
                    }
                })
                .font(.title3)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .modifyIf(k == CustomKey.empty) {
                    $0.buttonStyle(.plain)
                }
                .modifyIf(k == CustomKey.submit || k == CustomKey.next || k == CustomKey.prev) {
                    $0.buttonStyle(.borderedProminent)
                        .foregroundStyle(.background)
                }
                .modifyIf(k != CustomKey.empty && k != CustomKey.submit) {
                    $0.buttonStyle(.bordered)
                }
            }
            .previewBorder()
        }
    }
    
    @ViewBuilder
    var wheelInputView: some View {
        let keys: [CustomKey] = [.switchRep, .plus, .minus, .next]
        
        let columns = [
            GridItem(.flexible())
        ]
        
        GeometryReader { geometry in
            let width = geometry.size.width
            
            HStack(spacing: 8) {
                TimePickerView(model: $timePickerModel)
                    .previewBorder()
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(keys, id: \.sfSymbol) { k in
                        Button(action: {
                            keyPressHandler?(k)
                        }, label: {
                            ZStack {
                                Color.clear
                                k.view
                            }
                        })
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .modifyIf(k == CustomKey.empty) {
                            $0.buttonStyle(.plain)
                        }
                        .modifyIf(k == CustomKey.submit || k == CustomKey.next || k == CustomKey.prev) {
                            $0.buttonStyle(.borderedProminent)
                                .foregroundStyle(.background)
                        }
                        .modifyIf(k != CustomKey.empty && k != CustomKey.submit) {
                            $0.buttonStyle(.bordered)
                        }
                    }
                }
                .frame(width: max(0, (width - 24) / 4))
                .previewBorder()
            }
        }
    }
}

public struct TimeInputKeyboard: View {
    
    @Binding private var value: String
    
    private var keyPressHandler : KeyPressHandler?
    private var timeChangeHandler : TimeChangeHandler?
    
    @State private var timePickerModel = TimerPickerModel()

    public init(value: Binding<String>, keyPressHandler: KeyPressHandler? = nil) {
        self._value = value
        self.keyPressHandler = keyPressHandler
    }
    
    public var body: some View {
        timeInputControl
            .onChange(of: timePickerModel.totalTimeForCurrentSelection, { oldValue, newValue in
                timeChangeHandler?(TimeInterval(newValue))
                print(newValue.asTimestamp)
            })
        .foregroundStyle(.primary)
        .frame(maxHeight: 240)
        .padding([.leading, .bottom, .trailing])
    }
    
    
    @ViewBuilder
    var timeInputControl: some View {
        let keys: [CustomKey] = [.next, .plus, .minus, .submit]
        
        let columns = [
            GridItem(.flexible())
        ]
        
        GeometryReader { geometry in
            let width = geometry.size.width
            
            HStack(spacing: 8) {
                TimePickerView(model: $timePickerModel)
                    .previewBorder()
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(keys, id: \.sfSymbol) { k in
                        Button(action: {
                            keyPressHandler?(k)
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
                        .modifyIf(k != CustomKey.empty) {
                            $0.buttonStyle(.bordered)
                        }
                        .modifyIf(k == CustomKey.empty) {
                            $0.buttonStyle(.plain)
                        }
                    }
                }
                .frame(width: (width - 24) / 4)
                .previewBorder()
            }
        }
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable @State var value: String = "12"
    @Previewable @State var mode: RepInputMode = .timeCount
    @Previewable @State var mode2: RepInputMode = .repCount
    
    return VStack(spacing: 40) {
        RepInputKeyboard(mode: mode)
        RepInputKeyboard(mode: mode2)
    }
}
