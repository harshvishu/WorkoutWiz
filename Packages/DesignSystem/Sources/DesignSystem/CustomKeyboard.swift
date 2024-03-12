//
//  CustomKeyboard.swift
//
//
//  Created by harsh vishwakarma on 15/01/24.
//

import SwiftUI
import OSLog

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
        }
    }
}

public typealias KeyPressHandler = (CustomKey) -> ()
public typealias TimeChangeHandler = (TimeInterval) -> ()

public enum RepInputMode {
    case repCount
    case timeCount
}

public struct RepInputKeyboard: View {
    
    @Binding private var value: String
    @Binding private var mode: RepInputMode
    @State private var timePickerModel = TimerPickerModel()

    private var keyPressHandler : KeyPressHandler?
    private var timeChangeHandler : TimeChangeHandler?
    
    public init(
        value: Binding<String>,
        mode: Binding<RepInputMode>,
        keyPressHandler: KeyPressHandler? = nil,
        timeChangeHandler: TimeChangeHandler? = nil
    ) {
        self._value = value
        self._mode = mode
        self.keyPressHandler = keyPressHandler
        self.timeChangeHandler = timeChangeHandler
    }
    
    public var body: some View {
        Group {
            switch mode {
            case .repCount:
                repInputControl
            case .timeCount:
                timeInputControl
                    .onChange(of: timePickerModel.totalTimeForCurrentSelection, { oldValue, newValue in
                        timeChangeHandler?(TimeInterval(newValue))
                    })
            }
        }
        .foregroundStyle(.primary)
        .frame(maxHeight: 240)
        .padding([.leading, .bottom, .trailing])
    }
    
    @ViewBuilder
    var repInputControl: some View {
        let keys: [CustomKey] = [.digit(1), .digit(2), .digit(3), .next,
                                 .digit(4), .digit(5), .digit(6), .plus,
                                 .digit(7), .digit(8), .digit(9), .minus,
                                 .empty, .digit(0), .delete, .submit]
        
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
            .previewBorder()
        }
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

#Preview {
    @State var value: String = "12"
    @State var mode: RepInputMode = .timeCount
    @State var mode2: RepInputMode = .repCount
    
    return VStack(spacing: 40) {
        RepInputKeyboard(value: $value, mode: $mode)
        RepInputKeyboard(value: $value, mode: $mode2)
    }
}
