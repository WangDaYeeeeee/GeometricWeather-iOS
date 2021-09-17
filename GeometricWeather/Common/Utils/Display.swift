//
//  Display.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/15.
//

import Foundation
import UIKit

// MARK: - constants.

let maxPhoneAdaptiveWidth = 480.0
let maxTabletAdaptiveWidth = 512.0

// MARK: - theme.

func isDaylight() -> Bool {
    let hour = Calendar.current.component(.hour, from: Date())
    return 6 <= hour && hour < 18;
}

func isDaylight(location: Location) -> Bool {
    return location.daylight
}

// MARK: - time.

func formateTime(
    timeIntervalSine1970: TimeInterval,
    twelveHour: Bool,
    timezone: TimeZone = TimeZone.current
) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = twelveHour ? "h:mm aa" : "HH:mm"
    
    return formatter.string(
        from: Date(
            timeIntervalSince1970: timeIntervalSine1970 + Double((
                timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
            ))
        )
    )
}

func isToday(timezone: TimeZone) -> Bool {
    
    let currentDate = Date();
    let year = Calendar.current.component(.year, from: currentDate)
    let month = Calendar.current.component(.month, from: currentDate)
    let day = Calendar.current.component(.day, from: currentDate)
    
    let timezoneDate = Date(
        timeIntervalSince1970: Date().timeIntervalSince1970 + Double(
            timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
        )
    )
    let timezoneYear = Calendar.current.component(.year, from: timezoneDate)
    let timezoneMonth = Calendar.current.component(.month, from: timezoneDate)
    let timezoneDay = Calendar.current.component(.day, from: timezoneDate)

    return year == timezoneYear
        && month == timezoneMonth
        && day == timezoneDay
}

func isTwelveHour() -> Bool {
    if let formatter = DateFormatter.dateFormat(
        fromTemplate: "j",
        options: 0,
        locale: NSLocale.current
    ) {
        return formatter.contains("a")
    } else {
        return false
    }
}

// MARK: - tablet compat.

func getUIOrientation() -> UIInterfaceOrientation {
    return UIApplication.shared
        .windows
        .first?
        .windowScene?
        .interfaceOrientation ?? .unknown
}

func isTablet() -> Bool {
    return UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.phone
}

func isLandscape() -> Bool {
    return UIApplication
        .shared
        .windows
        .first?
        .windowScene?
        .interfaceOrientation
        .isLandscape ?? false
}

func getTabletAdaptiveWidth(maxWidth: Double) -> Double {
    if (!isTablet() && !isLandscape()) {
        return maxWidth
    }

    return getTabletAdaptiveWidth()
}

func getTabletAdaptiveWidth() -> Double {
    return isTablet()
        ? maxTabletAdaptiveWidth
        : maxPhoneAdaptiveWidth
}

func getTrendItemWidth(totalWidth: Double, margin: Double) -> Double {
    return (
        getTabletAdaptiveWidth(maxWidth: totalWidth) - 2 * margin
    ) / Double(
        getTrenItemDisplayCount()
    )
}

func getTrenItemDisplayCount() -> Int {
    return isTablet() || isLandscape() ? 7 : 5
}

// MARK: - text.

func getLocationText(location: Location) -> String {
    if !location.district.isEmpty {
        return location.district
    } else if !location.city.isEmpty {
        return location.city
    } else if !location.province.isEmpty {
        return location.province
    } else if location.currentPosition {
        return NSLocalizedString("current_location", comment: "")
    } else {
        return ""
    }
}

func getWeekText(week: Int) -> String {
    return NSLocalizedString("week_\(week)", comment: "")
}

func getHourText(hour: Int) -> String {
    return "\(hour)\(NSLocalizedString("of_clock", comment: ""))"
}

func getAirQualityText(level: Int) -> String {
    if level < 1 || 6 < level {
        return ""
    }
    
    return NSLocalizedString("aqi_\(level)", comment: "")
}

func getWindLevelText(level: Int) -> String {
    if level < 0 || 12 < level {
        return ""
    }
    
    return NSLocalizedString("wind_\(level)", comment: "")
}

func getShortWindText(wind: Wind) -> String {
    return wind.direction + " " + getWindLevelText(level: wind.level)
}

func getWindText(wind: Wind, unit: SpeedUnit) -> String {
    var text = wind.direction
    
    if let speed = wind.speed {
        text += " " + unit.formatValueWithUnit(
            speed,
            unit: NSLocalizedString("speed_unit_kph", comment: "")
        )
    }
    
    text += " (" + getWindLevelText(level: wind.level) + ")"
    
    if !wind.degree.noDirection {
        text += " " + wind.degree.getWindArrow()
    }
    
    return text
}

// reverse:   day / night
// otherwise: night / day
func getDayNightTemperatureText(
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

// MARK: - color.

func getLevelColor(_ level: Int) -> UIColor {
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
