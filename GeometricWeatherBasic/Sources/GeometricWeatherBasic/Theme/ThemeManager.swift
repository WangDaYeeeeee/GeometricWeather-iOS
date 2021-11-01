//
//  Theme.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import UIKit
import SwiftUI

// MARK: - constants.

public let navBarHeight = 44.0
public let navBarOpacity = 0.5

public let cardRadius = 18.0

public let littleMargin = 12.0
public let normalMargin = 24.0

public let colorLevel1 = UIColor.colorFromRGB(0x72d572);
public let colorLevel2 = UIColor.colorFromRGB(0xffca28);
public let colorLevel3 = UIColor.colorFromRGB(0xffa726);
public let colorLevel4 = UIColor.colorFromRGB(0xe52f35);
public let colorLevel5 = UIColor.colorFromRGB(0x99004c);
public let colorLevel6 = UIColor.colorFromRGB(0x7e0023);

public let precipitationProbabilityColor = UIColor { traitCollection in
    if traitCollection.userInterfaceStyle == .light {
        return .colorFromRGB(0x2a69c9)
    } else {
        return .colorFromRGB(0x82cffb)
    }
}

public let designTitleFont = UIFont.systemFont(ofSize: 128.0, weight: .ultraLight)
public let largeTitleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
public let titleFont = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
public let bodyFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
public let captionFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
public let miniCaptionFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
public let tinyCaptionFont = UIFont.systemFont(ofSize: 10.0, weight: .medium)

// MARK: - data.

public class ThemeManager {
    
    // singleton.
    
    public static let shared = ThemeManager(
        darkMode: SettingsManager.shared.darkMode
    )
    
    private init(darkMode: DarkMode) {
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
    
    public let weatherThemeDelegate = AnyWeatherThemeDelegate(
        MaterialWeatherThemeDelegate()
    )
    
    private var darkMode: DarkMode
    
    // interfaces.
    
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
            return .unspecified
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
            return .unspecified
        } else if darkMode.key == "dark_mode_light" {
            return .light
        } else if darkMode.key == "dark_mode_dark" {
            return .dark
        } else {
            return .unspecified
        }
    }
}
