//
//  SettingsManager.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation

class SettingsManager {
    
    // MARK: - singleton.
    
    static let shared = SettingsManager()

    private init() {
        UserDefaults.standard.register(defaults: [
            "alert_enabled": true,
            "precipitation_alert_enabled": false,
            "update_interval": "update_interval_2",
            "dark_mode": "dark_mode_auto",
            "exchange_day_night_temperature": false,
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
            "notification_enabled": false,
        ])
    }
    
    // MARK: - basic.
    
    var alertEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "alert_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "alert_enabled")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .alertEnabledChanged,
                object: newValue
            )
        }
    }
    
    var precipitationAlertEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "precipitation_alert_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "precipitation_alert_enabled")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .precipitationAlertEnabledChanged,
                object: newValue
            )
        }
    }
    
    var updateInterval: UpdateInterval {
        get {
            return UpdateInterval[
                UserDefaults.standard.string(forKey: "update_interval")
                ?? "update_interval_2"
            ]
        }
        set {
            UserDefaults.standard.set(newValue.key, forKey: "update_interval")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .updateIntervalChanged,
                object: newValue
            )
            
            registerPollingBackgroundTask()
        }
    }
    
    // MARK: - appearance.
    
    var darkMode: DarkMode {
        get {
            return DarkMode[
                UserDefaults.standard.string(forKey: "dark_mode")
                ?? "dark_mode_auto"
            ]
        }
        set {
            UserDefaults.standard.set(newValue.key, forKey: "dark_mode")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .darkModeChanged,
                object: newValue
            )
            
            ThemeManager.shared.update(darkMode: newValue)
        }
    }
    
    var exchangeDayNightTemperature: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "exchange_day_night_temperature")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "exchange_day_night_temperature")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .exchangeDayNightTemperatureChanged,
                object: newValue
            )
        }
    }
    
    // MARK: - service provider.
    
    var weatherSource: WeatherSource {
        get {
            return WeatherSource[
                UserDefaults.standard.string(forKey: "weather_source")
                ?? "weather_source_accu"
            ]
        }
        set {
            UserDefaults.standard.set(newValue.key, forKey: "weather_source")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .weatherSourceChanged,
                object: newValue
            )
        }
    }
    
    // MARK: - unit.
    
    var temperatureUnit: TemperatureUnit {
        get {
            return TemperatureUnit[
                UserDefaults.standard.string(forKey: "temperature_unit") ?? ""
            ]
        }
        set {
            UserDefaults.standard.set(newValue.key, forKey: "temperature_unit")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .temperatureUnitChanged,
                object: newValue
            )
        }
    }
    
    var precipitationUnit: PrecipitationUnit {
        get {
            return PrecipitationUnit[
                UserDefaults.standard.string(forKey: "precipitation_unit") ?? ""
            ]
        }
        set {
            UserDefaults.standard.set(newValue.key, forKey: "precipitation_unit")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .precipitationUnitChanged,
                object: newValue
            )
        }
    }
    
    var speedUnit: SpeedUnit {
        get {
            return SpeedUnit[
                UserDefaults.standard.string(forKey: "speed_unit") ?? ""
            ]
        }
        set {
            UserDefaults.standard.set(newValue.key, forKey: "speed_unit")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .speedUnitChanged,
                object: newValue
            )
        }
    }
    
    var pressureUnit: PressureUnit {
        get {
            return PressureUnit[
                UserDefaults.standard.string(forKey: "pressure_unit") ?? ""
            ]
        }
        set {
            UserDefaults.standard.set(newValue.key, forKey: "pressure_unit")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .pressureUnitChanged,
                object: newValue
            )
        }
    }
    
    var distanceUnit: DistanceUnit {
        get {
            return DistanceUnit[
                UserDefaults.standard.string(forKey: "distance_unit") ?? ""
            ]
        }
        set {
            UserDefaults.standard.set(newValue.key, forKey: "distance_unit")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .distanceUnitChanged,
                object: newValue
            )
        }
    }
    
    // MARK: - forecast.
    
    var todayForecastEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "today_forecast_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "today_forecast_enabled")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .todayForecastTimeChanged,
                object: newValue
            )
        }
    }
    
    var todayForecastTime: String {
        get {
            return UserDefaults.standard.string(forKey: "today_forecast_time") ?? "08:00"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "today_forecast_time")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .todayForecastTimeChanged,
                object: newValue
            )
        }
    }
    var todayForecastDate: Date {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.timeZone = .current
            
            return formatter.date(from: self.todayForecastTime) ?? Date()
        }
        set {
            printLog(keyword: "testing", content: "set")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
                        
            self.todayForecastTime = formatter.string(from: newValue)
        }
    }
    
    var tomorrowForecastEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "tomorrow_forecast_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "tomorrow_forecast_enabled")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .tomorrowForecastEnabledChanged,
                object: newValue
            )
        }
    }
    
    var tomorrowForecastTime: String {
        get {
            return UserDefaults.standard.string(forKey: "tomorrow_forecast_time") ?? "20:00"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "tomorrow_forecast_time")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .tomorrowForecastTimeChanged,
                object: newValue
            )
        }
    }
    var tomorrowForecastDate: Date {
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
    
    // MARK: - notification.
    
    var notificationEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "notification_enabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "notification_enabled")
            
            NotificationCenter.default.post(
                name: .settingChanged,
                object: nil
            )
            NotificationCenter.default.post(
                name: .notificationEnabledChanged,
                object: newValue
            )
        }
    }
}
