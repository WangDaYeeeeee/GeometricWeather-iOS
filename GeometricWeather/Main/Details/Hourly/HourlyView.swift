//
//  HourlyView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/6/16.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

// MARK: - hourly view.

struct HourlyView: View {
    
    let weather: Weather
    let index: Int
    let timezone: TimeZone
    
    var body: some View {
        List {
            HourlySection(weather: self.weather, index: self.index, timezone: self.timezone)
        }.listStyle(
            .insetGrouped
        ).background(
            Color.clear
        )
    }
}

// MARK: - daily section.

struct HourlySection: View {
    
    let weather: Weather
    let index: Int
    let timezone: TimeZone
    
    var body: some View {
        Section(
            header: HourlySectionTitleView(
                title: self.weather
                    .hourlyForecasts[self.index]
                    .formatDate(format: getLocalizedText("date_format_widget_long"))
            )
        ) {
            DetailsWeatherHeaderView(
                weatherCode: self.weather.hourlyForecasts[index].weatherCode,
                daylight: self.weather.hourlyForecasts[index].daylight,
                weatherText: self.weather.hourlyForecasts[index].weatherText,
                temperature: self.weather.hourlyForecasts[index].temperature
            )
            
            HourlyValuePart(weather: self.weather, index: self.index, timezone: self.timezone)
            
            if self.weather.hourlyForecasts[index].airQuality?.isValid() == true {
                DetailsAirQualityItemView(
                    aqi: self.weather.hourlyForecasts[index].airQuality!
                )
            }
        }
    }
}

struct HourlySectionTitleView: View {
    
    let title: String
    
    var body: some View {
        Text(self.title)
            .font(Font(bodyFont))
            .foregroundColor(Color(UIColor.secondaryLabel))
    }
}

struct HourlyValuePart: View {
    
    let weather: Weather
    let index: Int
    let timezone: TimeZone
    
    var body: some View {
        Group {
            if let precipitationIntensity = self.weather.hourlyForecasts[index].precipitationIntensity {
                DetailsValueItemView(
                    iconName: "drop",
                    title: getLocalizedText("precipitation_intensity"),
                    content: SettingsManager.shared.precipitationIntensityUnit.formatValueWithUnit(
                        precipitationIntensity,
                        unit: getLocalizedText(SettingsManager.shared.precipitationIntensityUnit.key)
                    )
                )
            }
            if let precipitationProb = self.weather.hourlyForecasts[index].precipitationProbability {
                DetailsValueItemView(
                    iconName: "drop",
                    title: getLocalizedText("precipitation_probability"),
                    content: getPercentText(precipitationProb, decimal: 1)
                )
            }
            if let wind = self.weather.hourlyForecasts[index].wind {
                DetailsValueItemView(
                    iconName: "wind",
                    title: getLocalizedText("wind"),
                    content: getWindText(
                        wind: wind,
                        unit: SettingsManager.shared.speedUnit
                    )
                )
            }
            if let pressure = self.weather.hourlyForecasts[index].pressure {
                DetailsValueItemView(
                    iconName: "gauge",
                    title: getLocalizedText("pressure"),
                    content: SettingsManager.shared.pressureUnit.formatValueWithUnit(
                        pressure,
                        unit: getLocalizedText(SettingsManager.shared.pressureUnit.key)
                    )
                )
            }
            if let humidity = self.weather.hourlyForecasts[index].humidity {
                DetailsValueItemView(
                    iconName: "humidity",
                    title: getLocalizedText("humidity"),
                    content: getPercentText(humidity, decimal: 1)
                )
            }
            if let visibility = self.weather.hourlyForecasts[index].visibility {
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
