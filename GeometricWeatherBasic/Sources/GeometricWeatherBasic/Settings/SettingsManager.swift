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

private let keyAlertEnabled = "alert_enabled"
private let keyPrecipitationAlertEnabled = "precipitation_alert_enabled"
private let keyUpdateInterval = "update_interval"
private let keyDarkMode = "dark_mode"
private let keyMainCards = "main_cards"
private let keyWeatherSource = prefixSync + "weather_source"
private let keyTemperatureUnit = prefixSync + "temperature_unit"
private let keyPrecipitationUnit = prefixSync + "precipitation_unit"
private let keySpeedUnit = prefixSync + "speed_unit"
private let keyPressureUnit = prefixSync + "pressure_unit"
private let keyDistanceUnit = prefixSync + "distance_unit"
private let keyTodayForecastEnabled = "today_forecast_enabled"
private let keyTodayForecastTime = "today_forecast_time"
private let keyTomorrowForecastEnabled = "tomorrow_forecast_enabled"
private let keyTomorrowForecastTime = "tomorrow_forecast_time"

public class SettingsManager {
    
    // MARK: - singleton.
    
    public static let shared = SettingsManager()

    private init() {
        SettingsSync.start(withPrefix: prefixSync)
        
        UserDefaults.shared.register(defaults: [
            keyAlertEnabled: true,
            keyPrecipitationAlertEnabled: false,
            keyUpdateInterval: "update_interval_2",
            keyMainCards: MainCard.all.map({ card in
                return card.key
            }),
            keyDarkMode: "dark_mode_auto",
            keyWeatherSource: "weather_source_accu",
            keyTemperatureUnit: "temperature_unit_c",
            keyPrecipitationUnit: "precipitation_unit_mm",
            keySpeedUnit: "speed_unit_kph",
            keyPressureUnit: "pressure_unit_mb",
            keyDistanceUnit: "distance_unit_km",
            keyTodayForecastEnabled: true,
            keyTodayForecastTime: "08:00",
            keyTomorrowForecastEnabled: true,
            keyTomorrowForecastTime: "20:00",
        ])
    }
    
    // MARK: - basic.
    
    public var alertEnabled: Bool {
        get {
            return UserDefaults.shared.bool(forKey: keyAlertEnabled)
        }
        set {
            UserDefaults.shared.set(newValue, forKey: keyAlertEnabled)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(AlertEnabledChanged(newValue))
        }
    }
    
    public var precipitationAlertEnabled: Bool {
        get {
            return UserDefaults.shared.bool(forKey: keyPrecipitationAlertEnabled)
        }
        set {
            UserDefaults.shared.set(newValue, forKey: keyPrecipitationAlertEnabled)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(PrecipitationAlertEnabledChanged(newValue))
        }
    }
    
    public var updateInterval: UpdateInterval {
        get {
//            return UpdateInterval[
//                UserDefaults.shared.string(forKey: keyUpdateInterval)
//                ?? "update_interval_2"
//            ]
            return UpdateInterval.twoHour
        }
        set {
            // do nothing.
//            UserDefaults.shared.set(newValue.key, forKey: keyUpdateInterval)
//
//            EventBus.shared.post(SettingsChangedEvent())
//            EventBus.shared.post(UpdateIntervalChanged(newValue))
        }
    }
    
    // MARK: - appearance.
    
    public var mainCards: [MainCard] {
        get {
            guard let keys = UserDefaults.shared.stringArray(
                forKey: keyMainCards
            ) else {
                return MainCard.all
            }
            
            return keys.map { key in
                return MainCard[key]
            }
        }
        set {
            var keys = [String]()
            for card in newValue {
                keys.append(card.key)
            }
            
            UserDefaults.shared.set(
                newValue.map({ card in
                    return card.key
                }),
                forKey: keyMainCards
            )
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(mainCardsChanged(newValue))
        }
    }
    
    public var darkMode: DarkMode {
        get {
            return DarkMode[
                UserDefaults.shared.string(forKey: keyDarkMode)
                ?? "dark_mode_auto"
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: keyDarkMode)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(DarkModeChanged(newValue))
        }
    }
    
    // MARK: - service provider.
    
    public var weatherSource: WeatherSource {
        get {
            return .caiYun
//            return WeatherSource[
//                UserDefaults.shared.string(forKey: keyWeatherSource)
//                ?? "weather_source_accu"
//            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: keyWeatherSource)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(WeatherSourceChanged(newValue))
        }
    }
    
    // MARK: - unit.
    
    public var temperatureUnit: TemperatureUnit {
        get {
            return TemperatureUnit[
                UserDefaults.shared.string(forKey: keyTemperatureUnit) ?? ""
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: keyTemperatureUnit)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(TemperatureUnitChanged(newValue))
        }
    }
    
    public var precipitationUnit: PrecipitationUnit {
        get {
            return PrecipitationUnit[
                UserDefaults.shared.string(forKey: keyPrecipitationUnit) ?? ""
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: keyPrecipitationUnit)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(PrecipitationUnitChanged(newValue))
        }
    }
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
    
    public var speedUnit: SpeedUnit {
        get {
            return SpeedUnit[
                UserDefaults.shared.string(forKey: keySpeedUnit) ?? ""
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: keySpeedUnit)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(SpeedUnitChanged(newValue))
        }
    }
    
    public var pressureUnit: PressureUnit {
        get {
            return PressureUnit[
                UserDefaults.shared.string(forKey: keyPressureUnit) ?? ""
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: keyPressureUnit)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(PressureUnitChanged(newValue))
        }
    }
    
    public var distanceUnit: DistanceUnit {
        get {
            return DistanceUnit[
                UserDefaults.shared.string(forKey: keyDistanceUnit) ?? ""
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: keyDistanceUnit)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(DistanceUnitChanged(newValue))
        }
    }
    
    // MARK: - forecast.
    
    public var todayForecastEnabled: Bool {
        get {
            return UserDefaults.shared.bool(forKey: keyTodayForecastEnabled)
        }
        set {
            UserDefaults.shared.set(newValue, forKey: keyTodayForecastEnabled)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(TodayForecastEnabledChanged(newValue))
        }
    }
    
    public var todayForecastTime: String {
        get {
            return UserDefaults.shared.string(forKey: keyTodayForecastTime) ?? "08:00"
        }
        set {
            UserDefaults.shared.set(newValue, forKey: keyTodayForecastTime)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(TodayForecastTimeChanged(newValue))
        }
    }
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
    
    public var tomorrowForecastEnabled: Bool {
        get {
            return UserDefaults.shared.bool(forKey: keyTomorrowForecastEnabled)
        }
        set {
            UserDefaults.shared.set(newValue, forKey: keyTomorrowForecastEnabled)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(TomorrowForecastEnabledChanged(newValue))
        }
    }
    
    public var tomorrowForecastTime: String {
        get {
            return UserDefaults.shared.string(forKey: keyTomorrowForecastTime) ?? "20:00"
        }
        set {
            UserDefaults.shared.set(newValue, forKey: keyTomorrowForecastTime)
            
            EventBus.shared.post(SettingsChangedEvent())
            EventBus.shared.post(TomorrowForecastTimeChanged(newValue))
        }
    }
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
