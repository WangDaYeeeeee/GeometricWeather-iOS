//
//  DailyView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/27.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

// MARK: - daily view.

struct DailyView: View {
    
    let weather: Weather
    let index: Int
    let timezone: TimeZone
    
    var body: some View {
        List {
            DaySection(weather: self.weather, index: self.index, timezone: self.timezone)
            NightSection(weather: self.weather, index: self.index, timezone: self.timezone)
            DailySection(weather: self.weather, index: self.index, timezone: self.timezone)
        }.listStyle(
            .insetGrouped
        ).background(
            Color.clear
        )
    }
}

// MARK: - day section.

struct DaySection: View {
    
    let weather: Weather
    let index: Int
    let timezone: TimeZone
    
    var body: some View {
        Section(
            header: DetailsSectionTitleView(key: "daytime")
        ) {
            DetailsWeatherHeaderView(
                weatherCode: self.weather.dailyForecasts[index].day.weatherCode,
                daylight: true,
                weatherText: self.weather.dailyForecasts[index].day.weatherPhase,
                temperature: self.weather.dailyForecasts[index].day.temperature
            )
            
            if let precipitationTotal = self.weather.dailyForecasts[index].day.precipitationTotal {
                if precipitationTotal > 0 {
                    DetailsValueItemView(
                        iconName: "drop",
                        title: getLocalizedText("precipitation"),
                        content: SettingsManager.shared.precipitationUnit.formatValueWithUnit(
                            precipitationTotal,
                            unit: getLocalizedText(SettingsManager.shared.precipitationUnit.key)
                        )
                    )
                }
            }
            if let precipitationIntensity = self.weather.dailyForecasts[index].day.precipitationIntensity {
                if precipitationIntensity > 0 {
                    DetailsValueItemView(
                        iconName: "drop",
                        title: getLocalizedText("precipitation_intensity"),
                        content: SettingsManager.shared.precipitationIntensityUnit.formatValueWithUnit(
                            precipitationIntensity,
                            unit: getLocalizedText(SettingsManager.shared.precipitationIntensityUnit.key)
                        )
                    )
                }
            }
            if let precipitationProb = self.weather.dailyForecasts[index].day.precipitationProbability {
                if precipitationProb > 0 {
                    DetailsValueItemView(
                        iconName: "drop",
                        title: getLocalizedText("precipitation_probability"),
                        content: getPercentText(precipitationProb, decimal: 1)
                    )
                }
            }
            if let wind = self.weather.dailyForecasts[index].day.wind {
                DetailsValueItemView(
                    iconName: "wind",
                    title: getLocalizedText("wind"),
                    content: getWindText(
                        wind: wind,
                        unit: SettingsManager.shared.speedUnit
                    )
                )
            }
            if let pressure = self.weather.dailyForecasts[index].day.pressure {
                DetailsValueItemView(
                    iconName: "gauge",
                    title: getLocalizedText("pressure"),
                    content: SettingsManager.shared.pressureUnit.formatValueWithUnit(
                        pressure,
                        unit: getLocalizedText(SettingsManager.shared.pressureUnit.key)
                    )
                )
            }
            if let humidity = self.weather.dailyForecasts[index].day.humidity {
                DetailsValueItemView(
                    iconName: "humidity",
                    title: getLocalizedText("humidity"),
                    content: getPercentText(humidity, decimal: 1)
                )
            }
            if let visibility = self.weather.dailyForecasts[index].day.visibility {
                DetailsValueItemView(
                    iconName: "eye",
                    title: getLocalizedText("visibility"),
                    content: SettingsManager.shared.distanceUnit.formatValueWithUnit(
                        visibility,
                        unit: getLocalizedText(SettingsManager.shared.distanceUnit.key)
                    )
                )
            }
        }
    }
}

// MARK: - night section.

struct NightSection: View {
    
    let weather: Weather
    let index: Int
    let timezone: TimeZone
    
    var body: some View {
        Section(
            header: DetailsSectionTitleView(key: "nighttime")
        ) {
            DetailsWeatherHeaderView(
                weatherCode: self.weather.dailyForecasts[index].night.weatherCode,
                daylight: false,
                weatherText: self.weather.dailyForecasts[index].night.weatherPhase,
                temperature: self.weather.dailyForecasts[index].night.temperature
            )
            
            if let precipitationTotal = self.weather.dailyForecasts[index].night.precipitationTotal {
                if precipitationTotal > 0 {
                    DetailsValueItemView(
                        iconName: "drop",
                        title: getLocalizedText("precipitation"),
                        content: SettingsManager.shared.precipitationUnit.formatValueWithUnit(
                            precipitationTotal,
                            unit: getLocalizedText(SettingsManager.shared.precipitationUnit.key)
                        )
                    )
                }
            }
            if let precipitationIntensity = self.weather.dailyForecasts[index].night.precipitationIntensity {
                if precipitationIntensity > 0 {
                    DetailsValueItemView(
                        iconName: "drop",
                        title: getLocalizedText("precipitation_intensity"),
                        content: SettingsManager.shared.precipitationIntensityUnit.formatValueWithUnit(
                            precipitationIntensity,
                            unit: getLocalizedText(SettingsManager.shared.precipitationIntensityUnit.key)
                        )
                    )
                }
            }
            if let precipitationProb = self.weather.dailyForecasts[index].night.precipitationProbability {
                if precipitationProb > 0 {
                    DetailsValueItemView(
                        iconName: "drop",
                        title: getLocalizedText("precipitation_probability"),
                        content: getPercentText(precipitationProb, decimal: 1)
                    )
                }
            }
            if let wind = self.weather.dailyForecasts[index].night.wind {
                DetailsValueItemView(
                    iconName: "wind",
                    title: getLocalizedText("wind"),
                    content: getWindText(
                        wind: wind,
                        unit: SettingsManager.shared.speedUnit
                    )
                )
            }
            if let pressure = self.weather.dailyForecasts[index].night.pressure {
                DetailsValueItemView(
                    iconName: "gauge",
                    title: getLocalizedText("pressure"),
                    content: SettingsManager.shared.pressureUnit.formatValueWithUnit(
                        pressure,
                        unit: getLocalizedText(SettingsManager.shared.pressureUnit.key)
                    )
                )
            }
            if let humidity = self.weather.dailyForecasts[index].night.humidity {
                DetailsValueItemView(
                    iconName: "humidity",
                    title: getLocalizedText("humidity"),
                    content: getPercentText(humidity, decimal: 1)
                )
            }
            if let visibility = self.weather.dailyForecasts[index].night.visibility {
                DetailsValueItemView(
                    iconName: "eye",
                    title: getLocalizedText("visibility"),
                    content: SettingsManager.shared.distanceUnit.formatValueWithUnit(
                        visibility,
                        unit: getLocalizedText(SettingsManager.shared.distanceUnit.key)
                    )
                )
            }
        }
    }
}

// MARK: - daily section.

struct DailySection: View {
    
    let weather: Weather
    let index: Int
    let timezone: TimeZone
    
    var body: some View {
        Section(
            header: DetailsSectionTitleView(key: "daily_overview")
        ) {
            DailyValuePart(weather: self.weather, index: self.index, timezone: self.timezone)
            
            if self.weather.dailyForecasts[index].airQuality.isValid() {
                DetailsAirQualityItemView(
                    aqi: self.weather.dailyForecasts[index].airQuality
                )
            }
            
            if self.weather.dailyForecasts[index].pollen.isValid() {
                DetailsPollenView(
                    pollen: self.weather.dailyForecasts[index].pollen
                )
            }
            
            if self.weather.dailyForecasts[index].sun.isValid()
                || self.weather.dailyForecasts[index].moon.isValid() {
                DetailsSunMoonItemView(
                    sun: self.weather.dailyForecasts[index].sun,
                    moon: self.weather.dailyForecasts[index].moon,
                    moonPhase: self.weather.dailyForecasts[index].moonPhase
                )
            }
        }
    }
}

struct DailyValuePart: View {
    
    let weather: Weather
    let index: Int
    let timezone: TimeZone
    
    var body: some View {
        Group {
            if let precipitationTotal = self.weather.dailyForecasts[index].precipitationTotal {
                if precipitationTotal > 0 {
                    DetailsValueItemView(
                        iconName: "drop",
                        title: getLocalizedText("precipitation"),
                        content: SettingsManager.shared.precipitationUnit.formatValueWithUnit(
                            precipitationTotal,
                            unit: getLocalizedText(SettingsManager.shared.precipitationUnit.key)
                        )
                    )
                }
            }
            if let precipitationIntensity = self.weather.dailyForecasts[index].precipitationIntensity {
                if precipitationIntensity > 0 {
                    DetailsValueItemView(
                        iconName: "drop",
                        title: getLocalizedText("precipitation_intensity"),
                        content: SettingsManager.shared.precipitationIntensityUnit.formatValueWithUnit(
                            precipitationIntensity,
                            unit: getLocalizedText(SettingsManager.shared.precipitationIntensityUnit.key)
                        )
                    )
                }
            }
            if let precipitationProb = self.weather.dailyForecasts[index].precipitationProbability {
                if precipitationProb > 0 {
                    DetailsValueItemView(
                        iconName: "drop",
                        title: getLocalizedText("precipitation_probability"),
                        content: getPercentText(precipitationProb, decimal: 1)
                    )
                }
            }
            if let wind = self.weather.dailyForecasts[index].wind {
                DetailsValueItemView(
                    iconName: "wind",
                    title: getLocalizedText("wind"),
                    content: getWindText(
                        wind: wind,
                        unit: SettingsManager.shared.speedUnit
                    )
                )
            }
            if let pressure = self.weather.dailyForecasts[index].pressure {
                DetailsValueItemView(
                    iconName: "gauge",
                    title: getLocalizedText("pressure"),
                    content: SettingsManager.shared.pressureUnit.formatValueWithUnit(
                        pressure,
                        unit: getLocalizedText(SettingsManager.shared.pressureUnit.key)
                    )
                )
            }
            if let humidity = self.weather.dailyForecasts[index].humidity {
                DetailsValueItemView(
                    iconName: "humidity",
                    title: getLocalizedText("humidity"),
                    content: getPercentText(humidity, decimal: 1)
                )
            }
            if let visibility = self.weather.dailyForecasts[index].visibility {
                DetailsValueItemView(
                    iconName: "eye",
                    title: getLocalizedText("visibility"),
                    content: SettingsManager.shared.distanceUnit.formatValueWithUnit(
                        visibility,
                        unit: getLocalizedText(SettingsManager.shared.distanceUnit.key)
                    )
                )
            }
            if self.weather.dailyForecasts[index].uv.isValid() {
                DetailsValueItemView(
                    iconName: "sun.max",
                    title: getLocalizedText("uv_index"),
                    content: self.weather.dailyForecasts[index].uv.getUVDescription()
                )
            }
        }
    }
}
