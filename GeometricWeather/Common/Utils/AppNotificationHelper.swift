//
//  AppNotificationHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/11.
//

import Foundation
import GeometricWeatherBasic

// MARK: - response.

struct AlertNotificationAction {}
struct ForecastNotificationAction {}

func responseNotificationAction(_ response: UNNotificationResponse) {
    let id = response.notification.request.identifier
    
    if id.starts(with: alertNotificationIdentifier) {
        EventBus.shared.post(AlertNotificationAction())
        return
    }
    
    EventBus.shared.post(ForecastNotificationAction())
}

// MARK: - alert.

private let alertNotificationIdentifier = "alert_notification"
private let alertNotificationGroupIdentifier = "alert_notification_group"

func checkToPushAlertNotification(newWeather: Weather, oldWeahter: Weather?) {
    
    var oldAlerts = Set<String>()
    for alert in oldWeahter?.alerts ?? [WeatherAlert]() {
        oldAlerts.insert(alert.description)
    }
    
    var newAlerts = [WeatherAlert]()
    for alert in newWeather.alerts {
        if oldAlerts.contains(alert.description) {
            continue
        }
        
        newAlerts.append(alert)
    }
    
    for alert in newAlerts {
        pushAlertNotification(alert: alert)
    }
}

private func pushAlertNotification(alert: WeatherAlert) {
    let content = UNMutableNotificationContent()
    content.title = alert.description + ", " + DateFormatter.localizedString(
        from: Date(timeIntervalSince1970: alert.time),
        dateStyle: .medium,
        timeStyle: .none
    )
    content.body = alert.content
    content.badge = NSNumber(value: 1)
    content.threadIdentifier = alertNotificationGroupIdentifier
    
    UNUserNotificationCenter.current().add(
        UNNotificationRequest(
            identifier: alertNotificationIdentifier + "_" + alert.alertId.description,
            content: content,
            trigger: nil
        )
    ) { _ in
        // do nothing.
    }
}

// MARK: - forecast.

private let todayForecastNotificationIdentifier = "today_forecast_notification"
private let tomorrowForecastNotificationIdentifier = "tomorrow_forecast_notification"
private let forecastNotificationGroupIdentifier = "forecast_notification_group"

func resetTodayForecastPendingNotification(weather: Weather) {

    UNUserNotificationCenter.current().removePendingNotificationRequests(
        withIdentifiers: [todayForecastNotificationIdentifier]
    )
    if !SettingsManager.shared.todayForecastEnabled {
        return
    }
    
    let unit = SettingsManager.shared.temperatureUnit
    
    let content = UNMutableNotificationContent()
    content.title = getLocalizedText("today")
    content.body = getLocalizedText("daytime")
    + " "
    + weather.dailyForecasts[0].day.weatherText
    + " "
    + unit.formatValueWithUnit(
        weather.dailyForecasts[0].day.temperature.temperature,
        unit: "°"
    )
    + "\n"
    + getLocalizedText("nighttime")
    + " "
    + weather.dailyForecasts[0].night.weatherText
    + " "
    + unit.formatValueWithUnit(
        weather.dailyForecasts[0].night.temperature.temperature,
        unit: "°"
    )
    content.threadIdentifier = forecastNotificationGroupIdentifier
        
    UNUserNotificationCenter.current().add(
        UNNotificationRequest(
            identifier: todayForecastNotificationIdentifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.hour, .minute],
                    from: SettingsManager.shared.todayForecastDate
                ),
                repeats: true
            )
        )
    ) { _ in
        // do nothing.
    }
}

func resetTomorrowForecastPendingNotification(weather: Weather) {
    
    UNUserNotificationCenter.current().removePendingNotificationRequests(
        withIdentifiers: [tomorrowForecastNotificationIdentifier]
    )
    if !SettingsManager.shared.tomorrowForecastEnabled {
        return
    }
    
    let unit = SettingsManager.shared.temperatureUnit
    
    let content = UNMutableNotificationContent()
    content.title = getLocalizedText("tomorrow")
    content.body = getLocalizedText("daytime")
    + " "
    + weather.dailyForecasts[1].day.weatherText
    + " "
    + unit.formatValueWithUnit(
        weather.dailyForecasts[1].day.temperature.temperature,
        unit: "°"
    )
    + "\n"
    + getLocalizedText("nighttime")
    + " "
    + weather.dailyForecasts[1].night.weatherText
    + " "
    + unit.formatValueWithUnit(
        weather.dailyForecasts[1].night.temperature.temperature,
        unit: "°"
    )
    content.threadIdentifier = forecastNotificationGroupIdentifier
        
    UNUserNotificationCenter.current().add(
        UNNotificationRequest(
            identifier: tomorrowForecastNotificationIdentifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.hour, .minute],
                    from: SettingsManager.shared.tomorrowForecastDate
                ),
                repeats: true
            )
        )
    ) { _ in
        // do nothing.
    }
}

// MARK: - precipitation.

private let precipitationNotificationIdentifier = "precipitation_notification"
private let precipitationNotificationGroupIdentifier = "precipitation_notification_group"

func checkToPushPrecipitationNotification(weather: Weather) {
    if !SettingsManager.shared.precipitationAlertEnabled {
        return
    }
    
    let lastPrecipitationTime = UserDefaults.standard.string(
        forKey: "lastPrecipitationTime"
    )
    let date = Date(
        timeIntervalSince1970: Double(
            lastPrecipitationTime ?? "0"
        ) ?? 0.0
    )
    if date.isToday() {
        return
    }
    if !isShortTermLiquid(weather) && !isLiquidDay(weather) {
        return
    }
    
    UserDefaults.standard.set(
        Date().timeIntervalSince1970.description,
        forKey: "lastPrecipitationTime"
    )
    
    let content = UNMutableNotificationContent()
    content.title = getLocalizedText("precipitation_overview")
    if isLiquidDay(weather) {
        content.body = getLocalizedText("feedback_today_precipitation_alert")
    } else {
        content.body = getLocalizedText("feedback_short_term_precipitation_alert")
    }
    content.badge = NSNumber(value: 1)
    content.threadIdentifier = precipitationNotificationGroupIdentifier
    
    UNUserNotificationCenter.current().add(
        UNNotificationRequest(
            identifier: precipitationNotificationIdentifier,
            content: content,
            trigger: nil
        )
    ) { _ in
        // do nothing.
    }
}

private func isShortTermLiquid(_ weather: Weather) -> Bool {
    for i in 0 ..< 4 {
        if isPrecipitationWeatherCode(
            weather.hourlyForecasts[i].weatherCode
        ) {
            return true
        }
    }
    return false
}

private func isLiquidDay(_ weather: Weather) -> Bool {
    return isPrecipitationWeatherCode(weather.dailyForecasts[0].day.weatherCode)
    || isPrecipitationWeatherCode(weather.dailyForecasts[0].night.weatherCode)
}
