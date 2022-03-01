//
//  Appearance.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

// MARK: - main card.

public struct MainCard: Option, Hashable, Identifiable {
    
    public typealias ImplType = MainCard
    
    public static let daily = MainCard(key: "daily_overview") { weather in
        return weather.dailyForecasts.count > 0
    }
    public static let hourly = MainCard(key: "hourly_overview") { weather in
        return weather.hourlyForecasts.count > 0
    }
    public static let airQuality = MainCard(key: "air_quality") { weather in
        return weather.current.airQuality.aqiLevel != nil
        && weather.current.airQuality.aqiIndex != nil
        && (weather.current.airQuality.pm25 != nil
            || weather.current.airQuality.pm10 != nil
            || weather.current.airQuality.so2 != nil
            || weather.current.airQuality.no2 != nil
            || weather.current.airQuality.o3 != nil
            || weather.current.airQuality.co != nil)
    }
    public static let allergen = MainCard(key: "allergen") { weather in
        return weather.dailyForecasts.count > 0
        && weather.dailyForecasts[0].pollen.isValid()
    }
    public static let sunMoon = MainCard(key: "sunrise_sunset") { weather in
        return weather.dailyForecasts.count > 0
        && weather.dailyForecasts[0].sun.isValid()
    }
    public static let details = MainCard(key: "life_details") { weather in
        return true
    }
    
    public static var all = [daily, hourly, airQuality, allergen, sunMoon, details]
    
    public static subscript(index: Int) -> MainCard {
        get {
            return MainCard.all[index]
        }
    }
    
    public static subscript(key: String) -> MainCard {
        get {
            for item in MainCard.all {
                if item.key == key {
                    return item
                }
            }
            return MainCard.all[0]
        }
    }
    
    public let key: String
    public let validator: (Weather) -> Bool
    
    public var id = UUID()
    
    public init(key: String, validator: @escaping (Weather) -> Bool) {
        self.key = key
        self.validator = validator
    }
    
    public func hash(into hasher: inout Hasher) {
        return self.key.hash(into: &hasher)
    }
}

// MARK: - dark mode.

public struct DarkMode: Option {
    
    public typealias ImplType = DarkMode
    
    public static let followSystem = DarkMode(key: "dark_mode_system")
    public static let auto = DarkMode(key: "dark_mode_auto")
    public static let light = DarkMode(key: "dark_mode_light")
    public static let dark = DarkMode(key: "dark_mode_dark")
    
    public static var all = [followSystem, auto, light, dark]
    
    public static subscript(index: Int) -> DarkMode {
        get {
            return DarkMode.all[index]
        }
    }
    
    public static subscript(key: String) -> DarkMode {
        get {
            for item in DarkMode.all {
                if item.key == key {
                    return item
                }
            }
            return DarkMode.all[0]
        }
    }
    
    public let key: String
    
    public init(key: String) {
        self.key = key
    }
}
