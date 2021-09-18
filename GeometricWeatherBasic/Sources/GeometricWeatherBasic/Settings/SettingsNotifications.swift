//
//  SettingsNotifications.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/15.
//

import Foundation

public extension Notification.Name {
    
    // send notifications without anything.
    
    // MARK: - total.
    
    static let settingChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.settingChanged"
    )
    
    // send notifications with new value.
    
    // MARK: - basic.
    
    static let alertEnabledChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.alertEnabledChanged"
    )
    static let precipitationAlertEnabledChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.precipitationAlertEnabledChanged"
    )
    static let updateIntervalChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.updateIntervalChanged"
    )
    
    // MARK: - appearance.
    
    static let darkModeChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.darkModeChanged"
    )
    static let exchangeDayNightTemperatureChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.exchangeDayNightTemperatureChanged"
    )
    
    // MARK: - service provider.
    
    static let weatherSourceChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.weatherSourceChanged"
    )
    
    // MARK: - unit.
    
    static let temperatureUnitChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.temperatureUnitChanged"
    )
    static let precipitationUnitChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.precipitationUnitChanged"
    )
    static let speedUnitChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.speedUnitChanged"
    )
    static let pressureUnitChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.pressureUnitChanged"
    )
    static let distanceUnitChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.distanceUnitChanged"
    )
    
    // MARK: - forecast.
    
    static let todayForecastEnabledChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.todayForecastEnabledChanged"
    )
    static let todayForecastTimeChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.todayForecastTimeChanged"
    )
    static let tomorrowForecastEnabledChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.tomorrowForecastEnabledChanged"
    )
    static let tomorrowForecastTimeChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.tomorrowForecastTimeChanged"
    )
    
    // MARK: - notification.
    
    static let notificationEnabledChanged = NSNotification.Name(
        "com.wangdaye.geometricweather.notificationEnabledChanged"
    )
}
