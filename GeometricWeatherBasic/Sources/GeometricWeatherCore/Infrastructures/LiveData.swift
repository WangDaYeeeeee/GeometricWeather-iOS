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

// MARK: - thread protection.

private func withMainThread<T>(_ run: () -> T) -> T {
    if Thread.isMainThread {
        return run()
    }
    
    return DispatchQueue.main.sync {
        run()
    }
}

// MARK: - live data.

public class LiveData<T> {
    
    // properties.
    
    fileprivate var innerValue: T {
        didSet {
            let hasNoCallback = withMainThread {
                self.observerCallbackMap.count == 0
            }
            if hasNoCallback {
                return
            }
            
            let value = self.innerValue
            
            DispatchQueue.main.async {
                self.dispatch(value)
            }
        }
    }
    
    public var value: T {
        set {
            withMainThread {
                self.innerValue = newValue
            }
        }
        get {
            return withMainThread {
                self.innerValue
            }
        }
    }
    
    fileprivate var observerCallbackMap = NSMapTable<AnyObject, CallbackWrapper<T>>(
        keyOptions: .weakMemory,
        valueOptions: .strongMemory
    )
    
    // life cycle.
    
    public init(_ value: T) {
        self.innerValue = value
    }
    
    deinit {
        self.observerCallbackMap.removeAllObjects()
    }
    
    // dispatch.
    
    fileprivate func dispatch(_ value: T) {
        guard let wrappers = self
            .observerCallbackMap
            .objectEnumerator()?
            .allObjects as? [CallbackWrapper<T>] else {
            return
        }
        wrappers.forEach { wrapper in
            wrapper.callback(value)
        }
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
        withMainThread {
            callback(self.value)
        }
    }
    
    public func addNonStickyObserver(
        _ observer: AnyObject,
        to callback: @escaping (T) -> Void
    ) {
        withMainThread {
            self.observerCallbackMap.setObject(
                CallbackWrapper(callback),
                forKey: observer
            )
        }
    }
    
    public func removeObserver(_ observer: AnyObject) {
        withMainThread {
            self.observerCallbackMap.removeObject(forKey: observer)
        }
    }
}

// MARK: - equaltable.

public class EqualtableLiveData<T: Equatable>: LiveData<T> {
    
    public override var value: T {
        set {
            withMainThread {
                if self.innerValue != newValue {
                    self.innerValue = newValue
                }
            }
        }
        get {
            return withMainThread {
                self.innerValue
            }
        }
    }
    
    public let filterUnnecessaryUpdate: Bool
    
    public override convenience init(_ value: T) {
        self.init(value, filterUnnecessaryUpdate: true)
    }
    
    public init(_ value: T, filterUnnecessaryUpdate: Bool) {
        self.filterUnnecessaryUpdate = filterUnnecessaryUpdate
        super.init(value)
    }
    
    override func dispatch(_ value: T) {
        if (value != self.value) {
            return
        }
        super.dispatch(value)
    }
}
