//
//  Theme.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import UIKit
import SwiftUI
import GeometricWeatherCore

public class ThemeManager {
    
    public static let weatherThemeDelegate = AnyWeatherThemeDelegate(
        MaterialWeatherThemeDelegate()
    )
    
    #if !os(watchOS)
    
    public init(darkMode: DarkMode) {
        self.homeOverrideUIStyle = EqualtableLiveData(
            Self.generateHomeUIUserInterfaceStyle(
                darkMode: darkMode,
                daylight: isDaylight()
            )
        )
        
        self.globalOverrideUIStyle = EqualtableLiveData(
            Self.generateGlobalUIUserInterfaceStyle(
                darkMode: darkMode,
                daylight: isDaylight()
            )
        )
        self.daylight = EqualtableLiveData(isDaylight())
                        
        self.darkMode = darkMode
    }
    
    // properties.
   
    public let homeOverrideUIStyle: EqualtableLiveData<UIUserInterfaceStyle>
    public let globalOverrideUIStyle: EqualtableLiveData<UIUserInterfaceStyle>
    public let daylight: EqualtableLiveData<Bool>
    
    private var darkMode: DarkMode
    
    // interfaces.
    
    public func update(location: Location) {
        self.update(darkMode: nil, location: location)
    }
    
    public func update(
        darkMode: DarkMode? = nil,
        location: Location? = nil
    ) {
        if let loc = location {
            self.daylight.value = isDaylight(location: loc)
        }
        if let dm = darkMode {
            self.darkMode = dm
        }
        
        homeOverrideUIStyle.value = Self.generateHomeUIUserInterfaceStyle(
            darkMode: self.darkMode,
            daylight: self.daylight.value
        )
        globalOverrideUIStyle.value = Self.generateGlobalUIUserInterfaceStyle(
            darkMode: self.darkMode,
            daylight: self.daylight.value
        )
    }
    
    private static func generateHomeUIUserInterfaceStyle(
        darkMode: DarkMode,
        daylight: Bool
    ) -> UIUserInterfaceStyle {
        if darkMode.key == "dark_mode_system" {
            return UIScreen.main.traitCollection.userInterfaceStyle
        } else if darkMode.key == "dark_mode_light" {
            return .light
        } else if darkMode.key == "dark_mode_dark" {
            return .dark
        } else {
            return daylight ? .light : .dark
        }
    }
    
    private static func generateGlobalUIUserInterfaceStyle(
        darkMode: DarkMode,
        daylight: Bool
    ) -> UIUserInterfaceStyle {
        if darkMode.key == "dark_mode_system" {
            return UIScreen.main.traitCollection.userInterfaceStyle
        } else if darkMode.key == "dark_mode_light" {
            return .light
        } else if darkMode.key == "dark_mode_dark" {
            return .dark
        } else {
            return .unspecified
        }
    }
    #else
    
    public init() {
        // do nothing.
    }
    #endif
}
