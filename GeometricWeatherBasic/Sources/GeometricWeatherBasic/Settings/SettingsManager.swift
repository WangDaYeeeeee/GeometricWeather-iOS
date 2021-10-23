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

public class SettingsManager {
    
    // MARK: - singleton.
    
    public static let shared = SettingsManager()

    private init() {
        UserDefaults.shared.register(defaults: [
            "alert_enabled": true,
            "precipitation_alert_enabled": false,
            "update_interval": "update_interval_2",
            "dark_mode": "dark_mode_auto",
            "weather_source": "weather_source_accu",
            "temperature_unit": "temperature_unit_c",
            "precipitation_unit": "precipitation_unit_mm",
            "speed_unit": "speed_unit_kph",
            "pressure_unit": "pressure_unit_mb",
            "distance_unit": "distance_unit_km",
            "today_forecast_enabled": true,
            "today_forecast_time": "08:00",
            "tomorrow_forecast_enabled": true,
            "tomorrow_forecast_time": "20:00",
        ])
    }
    
    // MARK: - basic.
    
    public var alertEnabled: Bool {
        get {
            return UserDefaults.shared.bool(forKey: "alert_enabled")
        }
        set {
            UserDefaults.shared.set(newValue, forKey: "alert_enabled")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .alertEnabledChanged,
                object: newValue
            )
        }
    }
    
    public var precipitationAlertEnabled: Bool {
        get {
            return UserDefaults.shared.bool(forKey: "precipitation_alert_enabled")
        }
        set {
            UserDefaults.shared.set(newValue, forKey: "precipitation_alert_enabled")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .precipitationAlertEnabledChanged,
                object: newValue
            )
        }
    }
    
    public var updateInterval: UpdateInterval {
        get {
            return UpdateInterval[
                UserDefaults.shared.string(forKey: "update_interval")
                ?? "update_interval_2"
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: "update_interval")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .updateIntervalChanged,
                object: newValue
            )
        }
    }
    
    // MARK: - appearance.
    
    public var darkMode: DarkMode {
        get {
            return DarkMode[
                UserDefaults.shared.string(forKey: "dark_mode")
                ?? "dark_mode_auto"
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: "dark_mode")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .darkModeChanged,
                object: newValue
            )
        }
    }
    
    // MARK: - service provider.
    
    public var weatherSource: WeatherSource {
        get {
            return .caiYun
//            return WeatherSource[
//                UserDefaults.shared.string(forKey: "weather_source")
//                ?? "weather_source_accu"
//            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: "weather_source")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .weatherSourceChanged,
                object: newValue
            )
        }
    }
    
    // MARK: - unit.
    
    public var temperatureUnit: TemperatureUnit {
        get {
            return TemperatureUnit[
                UserDefaults.shared.string(forKey: "temperature_unit") ?? ""
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: "temperature_unit")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .temperatureUnitChanged,
                object: newValue
            )
        }
    }
    
    public var precipitationUnit: PrecipitationUnit {
        get {
            return PrecipitationUnit[
                UserDefaults.shared.string(forKey: "precipitation_unit") ?? ""
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: "precipitation_unit")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .precipitationUnitChanged,
                object: newValue
            )
        }
    }
    
    public var speedUnit: SpeedUnit {
        get {
            return SpeedUnit[
                UserDefaults.shared.string(forKey: "speed_unit") ?? ""
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: "speed_unit")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .speedUnitChanged,
                object: newValue
            )
        }
    }
    
    public var pressureUnit: PressureUnit {
        get {
            return PressureUnit[
                UserDefaults.shared.string(forKey: "pressure_unit") ?? ""
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: "pressure_unit")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .pressureUnitChanged,
                object: newValue
            )
        }
    }
    
    public var distanceUnit: DistanceUnit {
        get {
            return DistanceUnit[
                UserDefaults.shared.string(forKey: "distance_unit") ?? ""
            ]
        }
        set {
            UserDefaults.shared.set(newValue.key, forKey: "distance_unit")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .distanceUnitChanged,
                object: newValue
            )
        }
    }
    
    // MARK: - forecast.
    
    public var todayForecastEnabled: Bool {
        get {
            return UserDefaults.shared.bool(forKey: "today_forecast_enabled")
        }
        set {
            UserDefaults.shared.set(newValue, forKey: "today_forecast_enabled")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .todayForecastTimeChanged,
                object: newValue
            )
        }
    }
    
    public var todayForecastTime: String {
        get {
            return UserDefaults.shared.string(forKey: "today_forecast_time") ?? "08:00"
        }
        set {
            UserDefaults.shared.set(newValue, forKey: "today_forecast_time")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .todayForecastTimeChanged,
                object: newValue
            )
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
            return UserDefaults.shared.bool(forKey: "tomorrow_forecast_enabled")
        }
        set {
            UserDefaults.shared.set(newValue, forKey: "tomorrow_forecast_enabled")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .tomorrowForecastEnabledChanged,
                object: newValue
            )
        }
    }
    
    public var tomorrowForecastTime: String {
        get {
            return UserDefaults.shared.string(forKey: "tomorrow_forecast_time") ?? "20:00"
        }
        set {
            UserDefaults.shared.set(newValue, forKey: "tomorrow_forecast_time")
            
            NotificationCenter.default.postToMainThread(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.postToMainThread(
                name: .tomorrowForecastTimeChanged,
                object: newValue
            )
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
