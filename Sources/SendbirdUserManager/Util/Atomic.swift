//
//  Atomic.swift
//
//
//  Created by 박종상 on 8/4/24.
//

import Foundation

@propertyWrapper
class Atomic<Value> {
    private var value: Value
    private let lock = NSRecursiveLock()

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    var wrappedValue: Value {
        get {
            value
        }
        set {
            lock.lock()
            value = newValue
            lock.unlock()
        }
    }
}
