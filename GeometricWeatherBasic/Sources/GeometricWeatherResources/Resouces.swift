//
//  File.swift
//  
//
//  Created by 王大爷 on 2022/5/4.
//

import Foundation
import SwiftUI
import UIKit
import GeometricWeatherCore

// MARK: - layout.

public let navBarHeight = 44.0
public let navBarOpacity = 0.5

public let cardRadius = 18.0

public let littleMargin = 12.0
public let normalMargin = 24.0

public let maxPhoneAdaptiveWidth = 480.0
public let maxTabletAdaptiveWidth = 512.0

public func isTablet() -> Bool {
    #if !os(watchOS)
    return UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.phone
    #else
    return false
    #endif
}

public func isLandscape() -> Bool {
    #if !os(watchOS)
    return UIApplication
        .shared
        .windows
        .first?
        .windowScene?
        .interfaceOrientation
        .isLandscape ?? false
    #else
    return false
    #endif
}

public func getTabletAdaptiveWidth(maxWidth: Double) -> Double {
    if (!isTablet() && !isLandscape()) {
        return maxWidth
    }

    return getTabletAdaptiveWidth()
}

public func getTabletAdaptiveWidth() -> Double {
    return isTablet()
        ? maxTabletAdaptiveWidth
        : maxPhoneAdaptiveWidth
}

public func getTrendItemWidth(totalWidth: Double, margin: Double) -> Double {
    return (
        getTabletAdaptiveWidth(maxWidth: totalWidth) - 2 * margin
    ) / Double(
        getTrenItemDisplayCount()
    )
}

public func getTrenItemDisplayCount() -> Int {
    return isTablet() || isLandscape() ? 8 : 6
}

// MARK: - colors.

public let colorLevel1 = UIColor.colorFromRGB(0x72d572)
public let colorLevel2 = UIColor.colorFromRGB(0xffca28)
public let colorLevel3 = UIColor.colorFromRGB(0xffa726)
public let colorLevel4 = UIColor.colorFromRGB(0xe52f35)
public let colorLevel5 = UIColor.colorFromRGB(0x99004c)
public let colorLevel6 = UIColor.colorFromRGB(0x7e0023)

#if !os(watchOS)
public let precipitationProbabilityColor = UIColor { traitCollection in
    if traitCollection.userInterfaceStyle == .light {
        return .colorFromRGB(0x2a69c9)
    } else {
        return .colorFromRGB(0x82cffb)
    }
}
#else
public let precipitationProbabilityColor = UIColor.cyan
#endif

public func getLevelColor(_ level: Int) -> UIColor {
    if (level < 2) {
        return colorLevel1
    }
    if (level < 3) {
        return colorLevel2
    }
    if (level < 4) {
        return colorLevel3
    }
    if (level < 5) {
        return colorLevel4
    }
    if (level < 6) {
        return colorLevel5
    }
    return colorLevel6
}

public let designTitleFont = UIFont.systemFont(ofSize: 128.0, weight: .ultraLight)
public let largeTitleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
public let titleFont = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
public let bodyFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
public let captionFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
public let miniCaptionFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
public let tinyCaptionFont = UIFont.systemFont(ofSize: 10.0, weight: .medium)

// MARK: - bundle.

public extension Bundle {
    
    static var shared: Bundle {
        return Bundle.module
    }
}

// MARK: - text.

public func getLocalizedText(_ key: String) -> String {
    let defaultValue = NSLocalizedString(
        key,
        tableName: "Default",
        bundle: .shared,
        value: "",
        comment: ""
    )
    
    return NSLocalizedString(
        key,
        tableName: nil,
        bundle: .shared,
        value: defaultValue,
        comment: ""
    )
}

public func getLocationText(location: Location) -> String {
    var text = ""
    
    if !location.district.isEmpty {
        text = location.district
    } else if !location.city.isEmpty {
        text = location.city
    } else if !location.province.isEmpty {
        text = location.province
    } else if location.currentPosition {
        text = getLocalizedText("current_location")
    }
    
    if !text.hasSuffix(")") {
        return text
    }
    guard let deleteBegin = text.lastIndex(of: "(") else {
        return text
    }
    return String(text[..<deleteBegin])
}

public func getWeekText(week: Int) -> String {
    return getLocalizedText("week_\(week)")
}

public func getHourText(hour: Int) -> String {
    return "\(hour)\(getLocalizedText("of_clock"))"
}

public func getAirQualityText(level: Int) -> String {
    if level < 1 || 6 < level {
        return ""
    }
    
    return getLocalizedText("aqi_\(level)")
}

public func getWindLevelText(level: Int) -> String {
    if level < 0 || 12 < level {
        return ""
    }
    
    return getLocalizedText("wind_\(level)")
}

public func getShortWindText(wind: Wind) -> String {
    var text = ""
    
    if let direction = wind.direction {
        text += direction + " "
    }
    
    return text + getWindLevelText(level: wind.level)
}

public func getWindText(wind: Wind, unit: SpeedUnit) -> String {
    var text = ""
    
    if let direction = wind.direction {
        text += direction + " "
    }
    
    if let speed = wind.speed {
        text += unit.formatValueWithUnit(
            speed,
            unit: getLocalizedText("speed_unit_kph")
        ) + " "
    }
    
    text += "(" + getWindLevelText(level: wind.level) + ")"
    
    if !wind.degree.noDirection {
        text += " " + wind.degree.getWindArrow()
    }
    
    return text
}

// reverse:   day / night
// otherwise: night / day
public func getDayNightTemperatureText(
    daytimeTemperature: Int,
    nighttimeTemperature: Int,
    unit: TemperatureUnit,
    reverseDayNightPosition: Bool,
    seperator: String = "/"
) -> String {
    let daytimeText = unit.formatValueWithUnit(
        daytimeTemperature,
        unit: "°"
    )
    let nighttimeText = unit.formatValueWithUnit(
        nighttimeTemperature,
        unit: "°"
    )
    
    if reverseDayNightPosition {
        return "\(daytimeText)\(seperator)\(nighttimeText)"
    } else {
        return "\(nighttimeText)\(seperator)\(daytimeText)"
    }
}

public func getPercentText(
    _ value: Double,
    decimal: Int
) -> String {
    return value.toString(decimal) + "%"
}

public func getPercentTextWithoutUnit(
    _ value: Double,
    decimal: Int
) -> String {
    return value.toString(decimal)
}
