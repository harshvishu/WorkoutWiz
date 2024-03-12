//
//  StructWrapper.swift
//  
//
//  Created by harsh vishwakarma on 12/03/24.
//

import Foundation

public class StructWrapper<T>: NSObject {

    public let value: T

    public init(_ _struct: T) {
        self.value = _struct
    }
}
