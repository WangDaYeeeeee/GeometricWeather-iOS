//
//  SettingsManager.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation

extension UserDefaults {
    
    private static let suiteInstance = UserDefaults(
        suiteName: "group.wangdaye.com.GeometricWeather"
    )
    
    static var shared: UserDefaults {
        get {
            return Self.suiteInstance ?? Self.shared
        }
    }
}

private let prefixSync = "syncable-"

private let keyTomorrowForecastEnabled = "tomorrow_forecast_enabled"
private let keyTomorrowForecastTime = "tomorrow_forecast_time"

public class SettingsManager {
    
    // MARK: - singleton.
    
    public static let shared = SettingsManager()

    private init() {
        SettingsSync.start(withPrefix: prefixSync)
    }
    
    // MARK: - basic.
    
    @UserDefaultValueWrapper<Bool, AlertEnabledChanged>(
        key: "alert_enabled",
        defaultValue: true
    ) public var alertEnabled
    
    @UserDefaultValueWrapper<Bool, PrecipitationAlertEnabledChanged>(
        key: "precipitation_alert_enabled",
        defaultValue: false
    ) public var precipitationAlertEnabled
    
    public let updateInterval = UpdateInterval.twoHour
    
    // MARK: - appearance.
    
    @ConvertableUserDefaultValueWrapper<String, DarkMode, DarkModeChanged>(
        key: "dark_mode",
        defaultValue: .auto,
        interfaceTypeToOrigin: { interface in
            return interface.key
        },
        originTypeToInterface: { origin in
            return DarkMode[origin]
        }
    ) public var darkMode
    
    @ConvertableUserDefaultValueWrapper<[String], [MainCard], MainCardsChanged>(
        key: "main_cards",
        defaultValue: MainCard.all,
        interfaceTypeToOrigin: { interface in
            return interface.map { item in
                item.key
            }
        },
        originTypeToInterface: { origin in
            return origin.map { item in
                MainCard[item]
            }
        }
    ) public var mainCards
    
    // MARK: - service provider.
    
    // key: prefixSync + "weather_source"
    public let weatherSource = WeatherSource.caiYun
    
    // MARK: - unit.
    
    @ConvertableUserDefaultValueWrapper<String, TemperatureUnit, TemperatureUnitChanged>(
        key: prefixSync + "temperature_unit",
        defaultValue: .c,
        interfaceTypeToOrigin: { interface in
            return interface.key
        },
        originTypeToInterface: { origin in
            return TemperatureUnit[origin]
        }
    ) public var temperatureUnit
    
    @ConvertableUserDefaultValueWrapper<String, PrecipitationUnit, PrecipitationUnitChanged>(
        key: prefixSync + "precipitation_unit",
        defaultValue: .mm,
        interfaceTypeToOrigin: { interface in
            return interface.key
        },
        originTypeToInterface: { origin in
            return PrecipitationUnit[origin]
        }
    ) public var precipitationUnit
    
    public var precipitationIntensityUnit: PrecipitationIntensityUnit {
        get {
            return PrecipitationIntensityUnit[
                self.precipitationUnit.key.replacingOccurrences(
                    of: "precipitation",
                    with: "precipitation_intensity"
                )
            ]
        }
    }
    
    @ConvertableUserDefaultValueWrapper<String, SpeedUnit, SpeedUnitChanged>(
        key: prefixSync + "speed_unit",
        defaultValue: .kph,
        interfaceTypeToOrigin: { interface in
            return interface.key
        },
        originTypeToInterface: { origin in
            return SpeedUnit[origin]
        }
    ) public var speedUnit
    
    @ConvertableUserDefaultValueWrapper<String, PressureUnit, PressureUnitChanged>(
        key: prefixSync + "pressure_unit",
        defaultValue: .mb,
        interfaceTypeToOrigin: { interface in
            return interface.key
        },
        originTypeToInterface: { origin in
            return PressureUnit[origin]
        }
    ) public var pressureUnit
    
    @ConvertableUserDefaultValueWrapper<String, DistanceUnit, DistanceUnitChanged>(
        key: prefixSync + "distance_unit",
        defaultValue: .km,
        interfaceTypeToOrigin: { interface in
            return interface.key
        },
        originTypeToInterface: { origin in
            return DistanceUnit[origin]
        }
    ) public var distanceUnit
    
    // MARK: - forecast.
    
    @UserDefaultValueWrapper<Bool, TodayForecastEnabledChanged>(
        key: "today_forecast_enabled",
        defaultValue: true
    ) public var todayForecastEnabled
    
    @UserDefaultValueWrapper<String, TodayForecastTimeChanged>(
        key: "today_forecast_time",
        defaultValue: "08:00"
    ) public var todayForecastTime
    
    public var todayForecastDate: Date {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.timeZone = .current
            
            return formatter.date(from: self.todayForecastTime) ?? Date()
        }
        set {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
                        
            self.todayForecastTime = formatter.string(from: newValue)
        }
    }
    
    @UserDefaultValueWrapper<Bool, TomorrowForecastEnabledChanged>(
        key: "tomorrow_forecast_enabled",
        defaultValue: true
    ) public var tomorrowForecastEnabled
    
    @UserDefaultValueWrapper<String, TomorrowForecastTimeChanged>(
        key: "tomorrow_forecast_time",
        defaultValue: "20:00"
    ) public var tomorrowForecastTime
    
    public var tomorrowForecastDate: Date {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.timeZone = .current
            
            return formatter.date(from: self.tomorrowForecastTime) ?? Date()
        }
        set {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
                        
            self.tomorrowForecastTime = formatter.string(from: newValue)
        }
    }
}
