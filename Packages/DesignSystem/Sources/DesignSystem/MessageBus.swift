//
//  File.swift
//
//
//  Created by harsh vishwakarma on 22/11/23.
//

import Foundation
import Combine
import Observation

public protocol MessageBus {
    associatedtype MessageType
    
    var signal: PassthroughSubject<MessageType, Never> {get}
    
    func send(_ message: MessageType)
}

public extension MessageBus {
    func send(_ value: MessageType) {
        signal.send(value)
    }
}

@Observable
public final class ConcreteMessageQueue<MessageType>: MessageBus {
    public typealias MessageType = MessageType
    
    public private(set) var signal: PassthroughSubject<MessageType, Never> = .init()
    
    public func send(_ value: MessageType) {
        signal.send(value)
    }
    
    public init() { }
}
