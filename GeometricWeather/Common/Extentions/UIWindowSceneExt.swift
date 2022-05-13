//
//  UIWindowSceneExt.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/5/12.
//

import UIKit
import GeometricWeatherCore
import GeometricWeatherTheme
import GeometricWeatherSettings

public extension UIWindowScene {
    
    private struct AssociatedKey {
        static var themeManager = "themeManager"
        static var eventBus = "eventBus"
    }
    
    // multi-scene compat.
    var themeManager: ThemeManager {
        get {
            if let cachedInstance = objc_getAssociatedObject(
                self,
                &AssociatedKey.themeManager
            ) as? ThemeManager {
                return cachedInstance
            }
            
            let instance = ThemeManager(darkMode: SettingsManager.shared.darkMode)
            EventBus.shared.register(instance, for: DarkModeChanged.self) { [weak instance] event in
                instance?.update(darkMode: event.newValue)
            }
            objc_setAssociatedObject(
                self,
                &AssociatedKey.themeManager,
                instance,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            return instance
        }
    }
    
    // multi-scene compat.
    var eventBus: EventBus {
        get {
            if let cachedInstance = objc_getAssociatedObject(
                self,
                &AssociatedKey.eventBus
            ) as? EventBus {
                return cachedInstance
            }
            
            let instance = EventBus()
            objc_setAssociatedObject(
                self,
                &AssociatedKey.eventBus,
                instance,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            return instance
        }
    }
}
