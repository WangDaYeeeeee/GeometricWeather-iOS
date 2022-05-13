//
//  File.swift
//  
//
//  Created by 王大爷 on 2021/10/29.
//

import Foundation

public class EventBus {
    
    // MARK: - singleton.
    
    public static let shared = EventBus()
    
    public init() {
        // do nothing.
    }
    
    // MARK: - properties.
    
    // key:   string reflection of event type.
    // value: LiveData<T?>
    var typeLiveDataMap = Dictionary<String, Any>()
    
    // MARK: - inner functions.
    
    func key<T>(_ type: T.Type) -> String {
        return String(reflecting: type)
    }
    
    func getLiveData<T>(_ type: T.Type) -> LiveData<T?> {
        let key = self.key(T.self)
        
        return self.typeLiveDataMap[key] as? LiveData<T?> ?? LiveData<T?>(nil)
    }
    
    func setLiveData<T>(
        _ liveData: LiveData<T?>
    ) {
        let key = self.key(T.self)
        
        self.typeLiveDataMap[key] = liveData
    }
    
    // MARK: - register.
    
    public func register<T>(
        _ observer: AnyObject,
        for type: T.Type,
        to callback: @escaping (T) -> Void
    ) {
        let liveData = self.getLiveData(T.self)
        liveData.addNonStickyObserver(observer) { value in
            if let v = value {
                callback(v)
            }
        }
        
        self.setLiveData(liveData)
    }
    
    public func stickyRegister<T>(
        _ observer: AnyObject,
        for type: T.Type,
        to callback: @escaping (T?) -> Void
    ) {
        let liveData = self.getLiveData(T.self)
        liveData.addObserver(observer) { value in
            callback(value)
        }
        
        self.setLiveData(liveData)
    }
    
    public func syncStickyRegister<T>(
        _ observer: AnyObject,
        for type: T.Type,
        to callback: @escaping (T?) -> Void
    ) {
        let liveData = self.getLiveData(T.self)
        liveData.syncAddObserver(observer) { value in
            callback(value)
        }
        
        self.setLiveData(liveData)
    }
    
    // MARK: - unregister.
    
    public func unregister<T>(
        _ observer: AnyObject,
        for type: T.Type
    ) {
        let liveData = self.getLiveData(T.self)
        liveData.removeObserver(observer)
        
        self.setLiveData(liveData)
    }
    
    // MARK: - post.
    
    public func post<T>(_ event: T) {
        let liveData = self.getLiveData(T.self)
        liveData.value = event
        
        self.setLiveData(liveData)
    }
}
