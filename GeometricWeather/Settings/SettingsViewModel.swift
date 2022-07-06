//
//  SettingsViewModel.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/5/13.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherSettings

class SettingsViewModel: ObservableObject {
    
    // MARK: - basic.
    
    @Published var alertEnabled = SettingsManager.shared.alertEnabled
    
    @Published var precipitationAlertEnabled = SettingsManager.shared.precipitationAlertEnabled
        
    // MARK: - appearance.
    
    @Published var darkModeIndex = DarkMode.all.firstIndex(
        of: SettingsManager.shared.darkMode
    ) ?? 0
    
    @Published var trendSyncEnabled = SettingsManager.shared.trendSyncEnabled
    
    // MARK: - unit.
    
    @Published var temperatureUnitIndex = TemperatureUnit.all.firstIndex(
        of: SettingsManager.shared.temperatureUnit
    ) ?? 0
    
    @Published var precipitationUnitIndex = PrecipitationUnit.all.firstIndex(
        of: SettingsManager.shared.precipitationUnit
    ) ?? 0
    
    @Published var speedUnitIndex = SpeedUnit.all.firstIndex(
        of: SettingsManager.shared.speedUnit
    ) ?? 0
    
    @Published var pressureUnitIndex = PressureUnit.all.firstIndex(
        of: SettingsManager.shared.pressureUnit
    ) ?? 0
    
    @Published var distanceUnitIndex = DistanceUnit.all.firstIndex(
        of: SettingsManager.shared.distanceUnit
    ) ?? 0
    
    // MARK: - forecast.
    
    @Published var todayForecastEnabled = SettingsManager.shared.todayForecastEnabled
    
    @Published var todayForecastDate = SettingsManager.shared.todayForecastDate
    
    @Published var tomorrowForecastEnabled = SettingsManager.shared.tomorrowForecastEnabled
    
    @Published var tomorrowForecastDate = SettingsManager.shared.tomorrowForecastDate
    
    init() {
        
        // basic.
        
        EventBus.shared.register(self, for: AlertEnabledChanged.self) { [weak self] event in
            self?.alertEnabled = event.newValue
        }
        EventBus.shared.register(self, for: PrecipitationAlertEnabledChanged.self) { [weak self] event in
            self?.precipitationAlertEnabled = event.newValue
        }
        
        // appearance.
        
        EventBus.shared.register(self, for: DarkModeChanged.self) { [weak self] event in
            self?.darkModeIndex = DarkMode.all.firstIndex(of: event.newValue) ?? 0
        }
        EventBus.shared.register(self, for: TrendSyncEnabledChanged.self) { [weak self] event in
            self?.trendSyncEnabled = event.newValue
        }
        
        // unit.
        
        EventBus.shared.register(self, for: TemperatureUnitChanged.self) { [weak self] event in
            self?.temperatureUnitIndex = TemperatureUnit.all.firstIndex(of: event.newValue) ?? 0
        }
        EventBus.shared.register(self, for: PrecipitationUnitChanged.self) { [weak self] event in
            self?.precipitationUnitIndex = PrecipitationUnit.all.firstIndex(of: event.newValue) ?? 0
        }
        EventBus.shared.register(self, for: SpeedUnitChanged.self) { [weak self] event in
            self?.speedUnitIndex = SpeedUnit.all.firstIndex(of: event.newValue) ?? 0
        }
        EventBus.shared.register(self, for: PressureUnitChanged.self) { [weak self] event in
            self?.pressureUnitIndex = PressureUnit.all.firstIndex(of: event.newValue) ?? 0
        }
        EventBus.shared.register(self, for: DistanceUnitChanged.self) { [weak self] event in
            self?.distanceUnitIndex = DistanceUnit.all.firstIndex(of: event.newValue) ?? 0
        }
        
        // forecast.
        
        EventBus.shared.register(self, for: TodayForecastEnabledChanged.self) { [weak self] event in
            self?.todayForecastEnabled = event.newValue
        }
        EventBus.shared.register(self, for: TodayForecastTimeChanged.self) { [weak self] _ in
            self?.todayForecastDate = SettingsManager.shared.todayForecastDate
        }
        EventBus.shared.register(self, for: TomorrowForecastEnabledChanged.self) { [weak self] event in
            self?.tomorrowForecastEnabled = event.newValue
        }
        EventBus.shared.register(self, for: TomorrowForecastTimeChanged.self) { [weak self] _ in
            self?.tomorrowForecastDate = SettingsManager.shared.tomorrowForecastDate
        }
    }
}
