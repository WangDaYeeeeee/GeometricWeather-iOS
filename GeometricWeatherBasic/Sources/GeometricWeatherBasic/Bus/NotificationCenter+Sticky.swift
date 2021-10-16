//
//  NotificationCenter+Sticky.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/16.
//

import Foundation

private var stickyCacheKey = 0

public extension NotificationCenter {

    private var stickyCache: Dictionary<String, Any?> {
        set {
            objc_setAssociatedObject(
                self,
                &stickyCacheKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        get {
            return objc_getAssociatedObject(
                self,
                &stickyCacheKey
            ) as? Dictionary<String, Any?> ?? Dictionary<String, Any?>()
        }
    }
    
    func postStikcy(_ notification: Notification) {
        if Thread.isMainThread {
            var cache = self.stickyCache
            cache[notification.name.rawValue] = notification.object
            self.stickyCache = cache
            
            self.post(notification)
            return
        }
        
        DispatchQueue.main.async {
            var cache = self.stickyCache
            cache[notification.name.rawValue] = notification.object
            self.stickyCache = cache
            
            self.post(notification)
        }
    }

    func postStikcy(
        name aName: NSNotification.Name,
        object anObject: Any?
    ) {
        if Thread.isMainThread {
            var cache = self.stickyCache
            cache[aName.rawValue] = anObject
            self.stickyCache = cache
            
            self.post(name: aName, object: anObject)
            return
        }
        
        DispatchQueue.main.async {
            var cache = self.stickyCache
            cache[aName.rawValue] = anObject
            self.stickyCache = cache
            
            self.post(name: aName, object: anObject)
        }
    }
    
    func addStickyObserver(
        _ observer: Any,
        selector aSelector: Selector,
        name aName: NSNotification.Name?,
        object anObject: Any?
    ) {
        self.addObserver(
            observer,
            selector: aSelector,
            name: aName,
            object: anObject
        )
        
        DispatchQueue.main.async {
            if let name = aName {
                var cache = self.stickyCache
                if !cache.keys.contains(name.rawValue) {
                    return
                }
                
                let stickyNotification = Notification(
                    name: name,
                    object: cache[name.rawValue] ?? nil,
                    userInfo: nil
                )
                cache.removeValue(forKey: name.rawValue)
                self.stickyCache = cache
                
                let _ = (observer as AnyObject).perform(
                    aSelector,
                    with: stickyNotification
                )
            }
        }
    }
}
