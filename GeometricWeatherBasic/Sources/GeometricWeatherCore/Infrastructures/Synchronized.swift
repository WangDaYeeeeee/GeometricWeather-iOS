//
//  File.swift
//  
//
//  Created by 王大爷 on 2022/5/30.
//

import Foundation

@propertyWrapper
public struct Synchronized<Value> {
    
    // value.

    private var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    // wrapper val.
    
    public var wrappedValue: Value {
        get {
            return self.ensureRunOnMainThread {
                self.value
            }
        }
        set {
            self.ensureRunOnMainThread {
                self.value = newValue
            }
        }
    }
    
    // sync method.
    
    public mutating func synchronizedRun<T>(
        _ runnable: (inout Value) -> T
    ) -> T {
        return self.ensureRunOnMainThread {
            return runnable(&self.value)
        }
    }
    
    private func ensureRunOnMainThread<T>(
        _ runnable: () -> T
    ) -> T {
        if Thread.isMainThread {
            return runnable()
        }
        
        return DispatchQueue.main.sync {
            runnable()
        }
    }
}
