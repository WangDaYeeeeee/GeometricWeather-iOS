//
//  NotificationCenter+Switcher.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/16.
//

import Foundation

public extension NotificationCenter {
    
    func postToMainThread(_ notification: Notification) {
        if Thread.isMainThread {
            self.post(notification)
            return
        }
        
        DispatchQueue.main.async {
            self.post(notification)
        }
    }

    func postToMainThread(
        name aName: NSNotification.Name,
        object anObject: Any?
    ) {
        if Thread.isMainThread {
            self.post(name: aName, object: anObject)
            return
        }
        
        DispatchQueue.main.async {
            self.post(name: aName, object: anObject)
        }
    }

    func postToMainThread(
        name aName: NSNotification.Name,
        object anObject: Any?,
        userInfo aUserInfo: [AnyHashable : Any]? = nil
    ) {
        if Thread.isMainThread {
            self.post(name: aName, object: anObject, userInfo: aUserInfo)
            return
        }
        
        DispatchQueue.main.async {
            self.post(name: aName, object: anObject, userInfo: aUserInfo)
        }
    }
}
