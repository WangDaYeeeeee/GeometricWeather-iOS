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
    
    fileprivate var callbackMap = Dictionary<AnyHashable, (T) -> Void>()
    
    // life cycle.
    
    public init(_ value: T) {
        self.value = value
    }
    
    deinit {
        self.callbackMap.removeAll()
    }
    
    // observer.
    
    public func observeValue(_ key: AnyHashable, callback: @escaping (T) -> Void) {
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
    
    public func syncObserveValue(_ key: AnyHashable, callback: @escaping (T) -> Void) {
        guard Thread.isMainThread else {
            fatalError("You need register a callback in main thread.")
        }
        
        // register callback.
        callbackMap[key] = callback
        // invoke callback at first register.
        callback(self.value)
    }
    
    public func stopObserve(_ key: AnyHashable) {
        guard Thread.isMainThread else {
            fatalError("You need register a callback in main thread.")
        }
        
        callbackMap.removeValue(forKey: key)
    }
}

// MARK: - equaltable.

public class EqualtableLiveData<T: Equatable>: LiveData<T> {
    
    public override var value: T {
        set {
            if self.innerValue != newValue {
                self.innerValue = newValue
            }
        }
        get {
            return self.innerValue
        }
    }
    private var innerValue: T {
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
        
    public override init(_ value: T) {
        self.innerValue = value
        super.init(value)
    }
}
