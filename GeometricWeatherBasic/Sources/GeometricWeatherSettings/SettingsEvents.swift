//
//  SettingsEvents.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/15.
//

import Foundation
import GeometricWeatherCore

// MARK: - settings changed.

public class SettingsChangedEvent {
    // do nothing.
}

// MARK: - settings value changed.

public class SettingsValueEvent<T> {
    
    public let newValue: T
    
    required init(_ newValue: T) {
        self.newValue = newValue
    }
}

// MARK: - basic.

public class AlertEnabledChanged: SettingsValueEvent<Bool> {}
public class PrecipitationAlertEnabledChanged: SettingsValueEvent<Bool> {}
public class UpdateIntervalChanged: SettingsValueEvent<UpdateInterval> {}
public class DynamicAppIconEnabledChanged: SettingsValueEvent<Bool> {}

// MARK: - appearance.

public class DarkModeChanged: SettingsValueEvent<DarkMode> {}
public class MainCardsChanged: SettingsValueEvent<[MainCard]> {}

// MARK: - service provider.

public class WeatherSourceChanged: SettingsValueEvent<WeatherSource> {}

// MARK: - unit.

public class TemperatureUnitChanged: SettingsValueEvent<TemperatureUnit> {}
public class PrecipitationUnitChanged: SettingsValueEvent<PrecipitationUnit> {}
public class SpeedUnitChanged: SettingsValueEvent<SpeedUnit> {}
public class PressureUnitChanged: SettingsValueEvent<PressureUnit> {}
public class DistanceUnitChanged: SettingsValueEvent<DistanceUnit> {}
    
// MARK: - forecast.

public class TodayForecastEnabledChanged: SettingsValueEvent<Bool> {}
public class TodayForecastTimeChanged: SettingsValueEvent<String> {}
public class TomorrowForecastEnabledChanged: SettingsValueEvent<Bool> {}
public class TomorrowForecastTimeChanged: SettingsValueEvent<String> {}
