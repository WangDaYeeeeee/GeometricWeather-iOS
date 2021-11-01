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
    
    public var value: T {
        willSet {
            self.checkMainThread()
        }
        didSet {
            DispatchQueue.main.async {
                guard let values = self.observerCallbackMap.objectEnumerator()?.allObjects as? [CallbackWrapper<T>] else {
                    return
                }
                values.forEach { wrapper in
                    wrapper.callback(self.value)
                }
            }
        }
    }
    
    fileprivate var observerCallbackMap = NSMapTable<AnyObject, CallbackWrapper<T>>(
        keyOptions: .weakMemory,
        valueOptions: .strongMemory
    )
    
    var observerCount: Int {
        get {
            return self.observerCallbackMap.count
        }
    }
    
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
        DispatchQueue.main.async {
            callback(self.value)
        }
    }
    
    public func syncAddObserver(
        _ observer: AnyObject,
        to callback: @escaping (T) -> Void
    ) {
        self.addNonStickyObserver(observer, to: callback)
        
        // invoke callback at first register.
        callback(self.value)
    }
    
    public func addNonStickyObserver(
        _ observer: AnyObject,
        to callback: @escaping (T) -> Void
    ) {
        self.checkMainThread()
        
        // register callback.
        self.observerCallbackMap.setObject(
            CallbackWrapper(callback),
            forKey: observer
        )
    }
    
    public func removeObserver(_ observer: AnyObject) {
        self.checkMainThread()
        
        self.observerCallbackMap.removeObject(forKey: observer)
    }
    
    fileprivate func checkMainThread() {
        guard Thread.isMainThread else {
            fatalError("You need update value in main thread.")
        }
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
            self.checkMainThread()
        }
        didSet {
            DispatchQueue.main.async {
                guard let values = self.observerCallbackMap.objectEnumerator()?.allObjects as? [CallbackWrapper<T>] else {
                    return
                }
                values.forEach { wrapper in
                    wrapper.callback(self.innerValue)
                }
            }
        }
    }
        
    public override init(_ value: T) {
        self.innerValue = value
        super.init(value)
    }
}
