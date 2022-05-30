//
//  LiveData.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/7.
//

import Foundation

// MARK: - wrap.

private class CallbackWrapper<T> {
    
    let callback: (T) -> Void
    
    init(_ callback: @escaping (T) -> Void) {
        self.callback = callback
    }
}

// MARK: - live data.

public class LiveData<T> {
    
    // properties.
    
    @Synchronized(nil)
    private var innerValue: T?
    
    public var value: T {
        set {
            var initSet = false
            self._innerValue.synchronizedRun { val in
                initSet = val == nil
                val = newValue
            }
            
            if initSet {
                return
            }
            
            DispatchQueue.main.async {
                guard let wrappers = self
                    .observerCallbackMap
                    .objectEnumerator()?
                    .allObjects as? [CallbackWrapper<T>] else {
                    return
                }
                if let value = self.innerValue {
                    wrappers.forEach { wrapper in
                        wrapper.callback(value)
                    }
                }
            }
        }
        get {
            self.innerValue!
        }
    }
    
    fileprivate var observerCallbackMap = NSMapTable<AnyObject, CallbackWrapper<T>>(
        keyOptions: .weakMemory,
        valueOptions: .strongMemory
    )
    
    // life cycle.
    
    public init(_ value: T) {
        self.value = value
    }
    
    deinit {
        self.observerCallbackMap.removeAllObjects()
    }
    
    // observer.
    
    public func addObserver(
        _ observer: AnyObject,
        to callback: @escaping (T) -> Void
    ) {
        self.addNonStickyObserver(observer, to: callback)
        
        // invoke callback at first register.
        DispatchQueue.main.async { [weak self] in
            if let value = self?.value {
                callback(value)
            }
        }
    }
    
    public func syncAddObserver(
        _ observer: AnyObject,
        to callback: @escaping (T) -> Void
    ) {
        self.addNonStickyObserver(observer, to: callback)
        
        // invoke callback at first register.
        self.ensureRunOnMainThread { [weak self] in
            if let value = self?.value {
                callback(value)
            }
        }
    }
    
    public func addNonStickyObserver(
        _ observer: AnyObject,
        to callback: @escaping (T) -> Void
    ) {
        self.ensureRunOnMainThread { [weak self] in
            self?.observerCallbackMap.setObject(
                CallbackWrapper(callback),
                forKey: observer
            )
        }
    }
    
    public func removeObserver(_ observer: AnyObject) {
        self.ensureRunOnMainThread { [weak self] in
            self?.observerCallbackMap.removeObject(forKey: observer)
        }
    }
    
    private func ensureRunOnMainThread(_ runnable: @escaping () -> Void) {
        if Thread.isMainThread {
            runnable()
            return
        }
        
        DispatchQueue.main.async {
            runnable()
        }
    }
}

// MARK: - equaltable.

public class EqualtableLiveData<T: Equatable>: LiveData<T> {
    
    @Synchronized(nil)
    private var innerValue: T?
    
    public override var value: T {
        set {
            var initSet = false
            var valueChanged = false
            
            self._innerValue.synchronizedRun { val in
                initSet = val == nil
                
                if val != newValue {
                    val = newValue
                    valueChanged = true
                }
            }
            
            if initSet {
                return
            }
            
            if valueChanged {
                DispatchQueue.main.async {
                    guard let wrappers = self
                        .observerCallbackMap
                        .objectEnumerator()?
                        .allObjects as? [CallbackWrapper<T>] else {
                        return
                    }
                    if let value = self.innerValue {
                        wrappers.forEach { wrapper in
                            wrapper.callback(value)
                        }
                    }
                }
            }
        }
        get {
            return self.innerValue!
        }
    }
}
