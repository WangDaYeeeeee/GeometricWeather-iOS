//
//  SettingsView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/15.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

struct SettingsView: View {
    
    @StateObject private var model = SettingsViewModel()
    
    var body: some View {
        List {
            Section(
                header: SettingsBodyView(
                    key: "settings_category_basic"
                )
            ) {
                SettingsToggleCellView(
                    titleKey: "settings_title_alert_notification_switch",
                    toggleOn: self.$model.alertEnabled
                )
                SettingsToggleCellView(
                    titleKey: "settings_title_precipitation_notification_switch",
                    toggleOn: self.$model.precipitationAlertEnabled
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
                    selectedIndex: self.$model.darkModeIndex
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
                    selectedIndex: self.$model.temperatureUnitIndex
                )
                SettingsListCellView(
                    titleKey: "settings_title_distance_unit",
                    keys: DistanceUnit.allKey,
                    selectedIndex: self.$model.distanceUnitIndex
                )
                SettingsListCellView(
                    titleKey: "settings_title_precipitation_unit",
                    keys: PrecipitationUnit.allKey,
                    selectedIndex: self.$model.precipitationUnitIndex
                )
                SettingsListCellView(
                    titleKey: "settings_title_pressure_unit",
                    keys: PressureUnit.allKey,
                    selectedIndex: self.$model.pressureUnitIndex
                )
                SettingsListCellView(
                    titleKey: "settings_title_speed_unit",
                    keys: SpeedUnit.allKey,
                    selectedIndex: self.$model.speedUnitIndex
                )
            }
            
            Section(
                header: SettingsBodyView(
                    key: "settings_category_forecast"
                )
            ) {
                SettingsToggleCellView(
                    titleKey: "settings_title_forecast_today",
                    toggleOn: self.$model.todayForecastEnabled
                )
                SettingsTimePickerCellView(
                    titleKey: "settings_title_forecast_today_time",
                    enabled: self.model.todayForecastEnabled,
                    selectedDate: self.$model.todayForecastDate
                )
                SettingsToggleCellView(
                    titleKey: "settings_title_forecast_tomorrow",
                    toggleOn: self.$model.tomorrowForecastEnabled
                )
                SettingsTimePickerCellView(
                    titleKey: "settings_title_forecast_tomorrow_time",
                    enabled: self.model.tomorrowForecastEnabled,
                    selectedDate: self.$model.tomorrowForecastDate
                )
            }
        }.listStyle(
            .insetGrouped
        ).onChange(of: self.model.alertEnabled) { newValue in
            SettingsManager.shared.alertEnabled = newValue
        }.onChange(of: self.model.precipitationAlertEnabled) { newValue in
            SettingsManager.shared.precipitationAlertEnabled = newValue
        }.onChange(of: self.model.darkModeIndex) { newValue in
            SettingsManager.shared.darkMode = DarkMode[newValue]
        }.onChange(of: self.model.temperatureUnitIndex) { newValue in
            SettingsManager.shared.temperatureUnit = TemperatureUnit[
                newValue
            ]
        }.onChange(of: self.model.precipitationUnitIndex) { newValue in
            SettingsManager.shared.precipitationUnit = PrecipitationUnit[
                newValue
            ]
        }.onChange(of: self.model.speedUnitIndex) { newValue in
            SettingsManager.shared.speedUnit = SpeedUnit[newValue]
        }.onChange(of: self.model.pressureUnitIndex) { newValue in
            SettingsManager.shared.pressureUnit = PressureUnit[
                newValue
            ]
        }.onChange(of: self.model.distanceUnitIndex) { newValue in
            SettingsManager.shared.distanceUnit = DistanceUnit[
                newValue
            ]
        }.onChange(of: self.model.todayForecastEnabled) { newValue in
            SettingsManager.shared.todayForecastEnabled = newValue
            resetTodayForecastPendingIntentInTask()
        }.onChange(of: self.model.todayForecastDate) { newValue in
            SettingsManager.shared.todayForecastDate = newValue
            resetTodayForecastPendingIntentInTask()
        }.onChange(of: self.model.tomorrowForecastEnabled) { newValue in
            SettingsManager.shared.tomorrowForecastEnabled = newValue
            resetTomorrowForecastPendingIntentInTask()
        }.onChange(of: self.model.tomorrowForecastDate) { newValue in
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
