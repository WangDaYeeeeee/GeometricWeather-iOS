//
//  SettingsView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/15.
//

import SwiftUI
import GeometricWeatherBasic

struct SettingsView: View {
    
    // MARK: - basic.
    
    @State private var alertEnabled = SettingsManager.shared.alertEnabled
    
    @State private var precipitationAlertEnabled = SettingsManager.shared.precipitationAlertEnabled
        
    // MARK: - appearance.
    
    @State private var darkModeIndex = DarkMode.all.firstIndex(
        of: SettingsManager.shared.darkMode
    ) ?? 0
    
    // MARK: - unit.
    
    @State private var temperatureUnitIndex = TemperatureUnit.all.firstIndex(
        of: SettingsManager.shared.temperatureUnit
    ) ?? 0
    
    @State private var precipitationUnitIndex = PrecipitationUnit.all.firstIndex(
        of: SettingsManager.shared.precipitationUnit
    ) ?? 0
    
    @State private var speedUnitIndex = SpeedUnit.all.firstIndex(
        of: SettingsManager.shared.speedUnit
    ) ?? 0
    
    @State private var pressureUnitIndex = PressureUnit.all.firstIndex(
        of: SettingsManager.shared.pressureUnit
    ) ?? 0
    
    @State private var distanceUnitIndex = DistanceUnit.all.firstIndex(
        of: SettingsManager.shared.distanceUnit
    ) ?? 0
    
    // MARK: - forecast.
    
    @State private var todayForecastEnabled = SettingsManager.shared.todayForecastEnabled
    
    @State private var todayForecastDate = SettingsManager.shared.todayForecastDate
    
    @State private var tomorrowForecastEnabled = SettingsManager.shared.tomorrowForecastEnabled
    
    @State private var tomorrowForecastDate = SettingsManager.shared.tomorrowForecastDate
    
    // MARK: - life cycle.
    
    var body: some View {
        List {
            Section(
                header: SettingsBodyView(
                    key: "settings_category_basic"
                )
            ) {
                SettingsToggleCellView(
                    titleKey: "settings_title_alert_notification_switch",
                    toggleOn: self.$alertEnabled
                )
                SettingsToggleCellView(
                    titleKey: "settings_title_precipitation_notification_switch",
                    toggleOn: self.$precipitationAlertEnabled
                )
            }
            
            Section(
                header: SettingsBodyView(
                    key: "settings_title_appearance"
                )
            ) {
                SettingsListCellView(
                    titleKey: "settings_title_dark_mode",
                    keys: DarkMode.allKey,
                    selectedIndex: self.$darkModeIndex
                )
            }
            
            Section(
                header: SettingsBodyView(
                    key: "settings_title_unit"
                )
            ) {
                SettingsListCellView(
                    titleKey: "settings_title_temperature_unit",
                    keys: TemperatureUnit.allKey,
                    selectedIndex: self.$temperatureUnitIndex
                )
                SettingsListCellView(
                    titleKey: "settings_title_distance_unit",
                    keys: DistanceUnit.allKey,
                    selectedIndex: self.$distanceUnitIndex
                )
                SettingsListCellView(
                    titleKey: "settings_title_precipitation_unit",
                    keys: PrecipitationUnit.allKey,
                    selectedIndex: self.$precipitationUnitIndex
                )
                SettingsListCellView(
                    titleKey: "settings_title_pressure_unit",
                    keys: PressureUnit.allKey,
                    selectedIndex: self.$pressureUnitIndex
                )
                SettingsListCellView(
                    titleKey: "settings_title_speed_unit",
                    keys: SpeedUnit.allKey,
                    selectedIndex: self.$speedUnitIndex
                )
            }
            
            Section(
                header: SettingsBodyView(
                    key: "settings_category_forecast"
                )
            ) {
                SettingsToggleCellView(
                    titleKey: "settings_title_forecast_today",
                    toggleOn: self.$todayForecastEnabled
                )
                SettingsTimePickerCellView(
                    titleKey: "settings_title_forecast_today_time",
                    enabled: self.todayForecastEnabled,
                    selectedDate: self.$todayForecastDate
                )
                SettingsToggleCellView(
                    titleKey: "settings_title_forecast_tomorrow",
                    toggleOn: self.$tomorrowForecastEnabled
                )
                SettingsTimePickerCellView(
                    titleKey: "settings_title_forecast_tomorrow_time",
                    enabled: self.tomorrowForecastEnabled,
                    selectedDate: self.$tomorrowForecastDate
                )
            }
        }.listStyle(
            .insetGrouped
        ).onChange(of: self.alertEnabled) { newValue in
            SettingsManager.shared.alertEnabled = newValue
        }.onChange(of: self.precipitationAlertEnabled) { newValue in
            SettingsManager.shared.precipitationAlertEnabled = newValue
        }.onChange(of: self.darkModeIndex) { newValue in
            SettingsManager.shared.darkMode = DarkMode[newValue]
            ThemeManager.shared.update(darkMode: DarkMode[newValue])
        }.onChange(of: self.temperatureUnitIndex) { newValue in
            SettingsManager.shared.temperatureUnit = TemperatureUnit[
                newValue
            ]
        }.onChange(of: self.precipitationUnitIndex) { newValue in
            SettingsManager.shared.precipitationUnit = PrecipitationUnit[
                newValue
            ]
        }.onChange(of: self.speedUnitIndex) { newValue in
            SettingsManager.shared.speedUnit = SpeedUnit[newValue]
        }.onChange(of: self.pressureUnitIndex) { newValue in
            SettingsManager.shared.pressureUnit = PressureUnit[
                newValue
            ]
        }.onChange(of: self.distanceUnitIndex) { newValue in
            SettingsManager.shared.distanceUnit = DistanceUnit[
                newValue
            ]
        }.onChange(of: self.todayForecastEnabled) { newValue in
            SettingsManager.shared.todayForecastEnabled = newValue
            resetTodayForecastPendingIntentInTask()
        }.onChange(of: self.todayForecastDate) { newValue in
            SettingsManager.shared.todayForecastDate = newValue
            resetTodayForecastPendingIntentInTask()
        }.onChange(of: self.tomorrowForecastEnabled) { newValue in
            SettingsManager.shared.tomorrowForecastEnabled = newValue
            resetTomorrowForecastPendingIntentInTask()
        }.onChange(of: self.tomorrowForecastDate) { newValue in
            SettingsManager.shared.tomorrowForecastDate = newValue
            resetTomorrowForecastPendingIntentInTask()
        }
    }
}

private func resetTodayForecastPendingIntentInTask() {
    Task(priority: .high) {
        if let weather = await DatabaseHelper.shared.asyncReadWeather(
            formattedId: await DatabaseHelper.shared.asyncReadLocations()[0].formattedId
        ) {
            await resetTodayForecastPendingNotification(weather: weather)
        }
    }
}

private func resetTomorrowForecastPendingIntentInTask() {
    Task(priority: .high) {
        if let weather = await DatabaseHelper.shared.asyncReadWeather(
            formattedId: await DatabaseHelper.shared.asyncReadLocations()[0].formattedId
        ) {
            await resetTomorrowForecastPendingNotification(weather: weather)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
