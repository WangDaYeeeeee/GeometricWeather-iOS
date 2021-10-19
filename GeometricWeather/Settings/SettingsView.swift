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
    
    @State private var updateInterval = SettingsManager.shared.updateInterval.key
    
    // MARK: - appearance.
    
    @State private var darkMode = SettingsManager.shared.darkMode.key
    
    // MARK: - service provider.
    
    @State private var weatherSource = SettingsManager.shared.weatherSource.key
    
    // MARK: - unit.
    
    @State private var temperatureUnit = SettingsManager.shared.temperatureUnit.key
    
    @State private var precipitationUnit = SettingsManager.shared.precipitationUnit.key
    
    @State private var speedUnit = SettingsManager.shared.speedUnit.key
    
    @State private var pressureUnit = SettingsManager.shared.pressureUnit.key
    
    @State private var distanceUnit = SettingsManager.shared.distanceUnit.key
    
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
                SettingsListCellView(
                    titleKey: "settings_title_refresh_rate",
                    keys: [
                        "update_interval_1",
                        "update_interval_2",
                        "update_interval_3",
                        "update_interval_4",
                    ],
                    selectedKey: self.$updateInterval
                )
            }
            
            Section(
                header: SettingsBodyView(
                    key: "settings_title_appearance"
                )
            ) {
                SettingsListCellView(
                    titleKey: "settings_title_dark_mode",
                    keys: [
                        "dark_mode_auto",
                        "dark_mode_system",
                        "dark_mode_light",
                        "dark_mode_dark",
                    ],
                    selectedKey: self.$darkMode
                )
            }
            
            Section(
                header: SettingsBodyView(
                    key: "settings_title_unit"
                )
            ) {
                SettingsListCellView(
                    titleKey: "settings_title_temperature_unit",
                    keys: [
                        "temperature_unit_c",
                        "temperature_unit_f",
                        "temperature_unit_k",
                    ],
                    selectedKey: self.$temperatureUnit
                )
                SettingsListCellView(
                    titleKey: "settings_title_distance_unit",
                    keys: [
                        "distance_unit_km",
                        "distance_unit_m",
                        "distance_unit_mi",
                        "distance_unit_nmi",
                        "distance_unit_ft",
                    ],
                    selectedKey: self.$distanceUnit
                )
                SettingsListCellView(
                    titleKey: "settings_title_precipitation_unit",
                    keys: [
                        "precipitation_unit_mm",
                        "precipitation_unit_cm",
                        "precipitation_unit_in",
                        "precipitation_unit_lpsqm",
                    ],
                    selectedKey: self.$precipitationUnit
                )
                SettingsListCellView(
                    titleKey: "settings_title_pressure_unit",
                    keys: [
                        "pressure_unit_mb",
                        "pressure_unit_kpa",
                        "pressure_unit_hpa",
                        "pressure_unit_atm",
                        "pressure_unit_mmhg",
                        "pressure_unit_inhg",
                        "pressure_unit_kgfpsqcm",
                    ],
                    selectedKey: self.$pressureUnit
                )
                SettingsListCellView(
                    titleKey: "settings_title_speed_unit",
                    keys: [
                        "speed_unit_kph",
                        "speed_unit_mps",
                        "speed_unit_kn",
                        "speed_unit_mph",
                        "speed_unit_ftps",
                    ],
                    selectedKey: self.$speedUnit
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
                    selectedDate: self.$todayForecastDate
                )
                SettingsToggleCellView(
                    titleKey: "settings_title_forecast_tomorrow",
                    toggleOn: self.$tomorrowForecastEnabled
                )
                SettingsTimePickerCellView(
                    titleKey: "settings_title_forecast_tomorrow_time",
                    selectedDate: self.$tomorrowForecastDate
                )
            }
        }.listStyle(
            GroupedListStyle()
        ).onChange(of: self.alertEnabled) { newValue in
            SettingsManager.shared.alertEnabled = newValue
        }.onChange(of: self.precipitationAlertEnabled) { newValue in
            SettingsManager.shared.precipitationAlertEnabled = newValue
        }.onChange(of: self.updateInterval) { newValue in
            SettingsManager.shared.updateInterval = UpdateInterval[
                updateInterval
            ]
        }.onChange(of: self.darkMode) { newValue in
            SettingsManager.shared.darkMode = DarkMode[newValue]
            ThemeManager.shared.update(darkMode: DarkMode[newValue])
        }.onChange(of: self.weatherSource) { newValue in
            SettingsManager.shared.weatherSource = WeatherSource[
                newValue
            ]
        }.onChange(of: self.temperatureUnit) { newValue in
            SettingsManager.shared.temperatureUnit = TemperatureUnit[
                newValue
            ]
        }.onChange(of: self.precipitationUnit) { newValue in
            SettingsManager.shared.precipitationUnit = PrecipitationUnit[
                newValue
            ]
        }.onChange(of: self.speedUnit) { newValue in
            SettingsManager.shared.speedUnit = SpeedUnit[newValue]
        }.onChange(of: self.pressureUnit) { newValue in
            SettingsManager.shared.pressureUnit = PressureUnit[
                newValue
            ]
        }.onChange(of: self.distanceUnit) { newValue in
            SettingsManager.shared.distanceUnit = DistanceUnit[
                newValue
            ]
        }.onChange(of: self.todayForecastEnabled) { newValue in
            SettingsManager.shared.todayForecastEnabled = newValue
            resetTodayForecastPendingIntent()
        }.onChange(of: self.todayForecastDate) { newValue in
            SettingsManager.shared.todayForecastDate = newValue
            resetTodayForecastPendingIntent()
        }.onChange(of: self.tomorrowForecastEnabled) { newValue in
            SettingsManager.shared.tomorrowForecastEnabled = newValue
            resetTomorrowForecastPendingIntent()
        }.onChange(of: self.tomorrowForecastDate) { newValue in
            SettingsManager.shared.tomorrowForecastDate = newValue
            resetTomorrowForecastPendingIntent()
        }
    }
}

private func resetTodayForecastPendingIntent() {
    DispatchQueue.global(qos: .background).async {
        if let weather = DatabaseHelper.shared.readWeather(
            formattedId: DatabaseHelper.shared.readLocations()[0].formattedId
        ) {
            resetTodayForecastPendingNotification(weather: weather)
        }
    }
}

private func resetTomorrowForecastPendingIntent() {
    DispatchQueue.global(qos: .background).async {
        if let weather = DatabaseHelper.shared.readWeather(
            formattedId: DatabaseHelper.shared.readLocations()[0].formattedId
        ) {
            resetTomorrowForecastPendingNotification(weather: weather)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
