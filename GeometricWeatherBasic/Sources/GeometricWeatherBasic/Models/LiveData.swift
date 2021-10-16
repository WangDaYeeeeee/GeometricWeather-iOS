//
//  LiveData.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/7.
//

import Foundation

// MARK: - live data.

public class LiveData<T> {
    
    // properties.
    
    public var value: T {
        willSet {
            guard Thread.isMainThread else {
                fatalError("You need update value in main thread.")
            }
        }
        didSet {
            DispatchQueue.main.async {
                for callback in self.callbackMap.values {
                    callback(self.value)
                }
            }
        }
    }
    
    fileprivate var callbackMap = Dictionary<String, (T) -> Void>()
    
    // life cycle.
    
    public init(_ value: T) {
        self.value = value
    }
    
    deinit {
        self.callbackMap.removeAll()
    }
    
    // observer.
    
    public func observeValue(_ key: String, callback: @escaping (T) -> Void) {
        guard Thread.isMainThread else {
            fatalError("You need register a callback in main thread.")
        }
        
        // register callback.
        callbackMap[key] = callback
        // invoke callback at first register.
        DispatchQueue.main.async {
            callback(self.value)
        }
    }
    
    public func syncObserveValue(_ key: String, callback: @escaping (T) -> Void) {
        guard Thread.isMainThread else {
            fatalError("You need register a callback in main thread.")
        }
        
        // register callback.
        callbackMap[key] = callback
        // invoke callback at first register.
        callback(self.value)
    }
    
    public func stopObserve(_ key: String) {
        guard Thread.isMainThread else {
            fatalError("You need register a callback in main thread.")
        }
        
        callbackMap.removeValue(forKey: key)
    }
}

// MARK: - equaltable.

public class EqualtableLiveData<T: Equatable> {
    
    // properties.
    
    public var value: T {
        willSet {
            guard Thread.isMainThread else {
                fatalError("You need update value in main thread.")
            }
            
            self.valueChanged = newValue != self.value
        }
        didSet {
            if !self.valueChanged {
                return
            }
            
            DispatchQueue.main.async {
                for callback in self.callbackMap.values {
                    callback(self.value)
                }
            }
        }
    }
    
    fileprivate var callbackMap = Dictionary<String, (T) -> Void>()
    
    private var valueChanged = false
    
    // life cycle.
    
    public init(_ value: T) {
        self.value = value
    }
    
    deinit {
        self.callbackMap.removeAll()
    }
    
    // observer.
    
    public func observeValue(_ key: String, callback: @escaping (T) -> Void) {
        guard Thread.isMainThread else {
            fatalError("You need register a callback in main thread.")
        }
        
        // register callback.
        callbackMap[key] = callback
        // invoke callback at first register.
        DispatchQueue.main.async {
            callback(self.value)
        }
    }
    
    public func syncObserveValue(_ key: String, callback: @escaping (T) -> Void) {
        guard Thread.isMainThread else {
            fatalError("You need register a callback in main thread.")
        }
        
        // register callback.
        callbackMap[key] = callback
        // invoke callback at first register.
        callback(self.value)
    }
    
    public func stopObserve(_ key: String) {
        guard Thread.isMainThread else {
            fatalError("You need register a callback in main thread.")
        }
        
        callbackMap.removeValue(forKey: key)
    }
}
