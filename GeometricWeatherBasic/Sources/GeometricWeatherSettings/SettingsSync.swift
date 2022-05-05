//
//  File.swift
//  
//
//  Created by 王大爷 on 2022/2/23.
//

import Foundation

private var keyPrefix = ""

private let kiCloudSyncNotification = "com.wangdaye.iCloudSyncDidUpdateToLatest"

class SettingsSync {
    
    @objc static func updateToiCloud(notificationObject: NSNotification) {
        
        for (key, value) in UserDefaults.shared.dictionaryRepresentation() {
            if !key.hasPrefix(keyPrefix) {
                continue
            }
            NSUbiquitousKeyValueStore.default.set(value, forKey: key)
        }
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    @objc static func updateFromiCloud(notificationObject: NSNotification) {
        
        NotificationCenter.default.removeObserver(
            self,
            name: UserDefaults.didChangeNotification,
            object: nil
        )
        
        for (key, value) in NSUbiquitousKeyValueStore.default.dictionaryRepresentation {
            if !key.hasPrefix(keyPrefix) {
                continue
            }
            UserDefaults.shared.set(value, forKey: key)
        }
        UserDefaults.shared.synchronize()
        
        // enable NSUserDefaultsDidChangeNotification notifications again
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateToiCloud(notificationObject:)),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
        NotificationCenter.default.post(
            name: NSNotification.Name(kiCloudSyncNotification),
            object: nil
        )
    }
    
    static func start(withPrefix prefixToSync: String) {
        keyPrefix = prefixToSync
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFromiCloud(notificationObject:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateToiCloud(notificationObject:)),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
}
