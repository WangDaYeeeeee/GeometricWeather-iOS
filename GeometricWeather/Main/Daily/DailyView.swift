//
//  DailyView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/27.
//

import SwiftUI
import GeometricWeatherBasic

struct DailyView: View {
    
    let weather: Weather
    let index: Int
    let timezone: TimeZone
    
    var body: some View {
        List {
            Section(
                header: DailySectionTitle(key: "daytime")
            ) {
                HalfDayHeader(
                    halfDay: self.weather.dailyForecasts[index].day,
                    daylight: true
                )
                
                if let precipitationTotal = self.weather.dailyForecasts[index].day.precipitationTotal {
                    DailyValueItem(
                        title: NSLocalizedString("precipitation", comment: ""),
                        content: SettingsManager.shared.precipitationUnit.formatValueWithUnit(
                            precipitationTotal,
                            unit: NSLocalizedString(
                                SettingsManager.shared.precipitationUnit.key,
                                comment: ""
                            )
                        )
                    )
                }
                if let precipitationIntensity = self.weather.dailyForecasts[index].day.precipitationIntensity {
                    DailyValueItem(
                        title: NSLocalizedString("precipitation_intensity", comment: ""),
                        content: SettingsManager.shared.precipitationIntensityUnit.formatValueWithUnit(
                            precipitationIntensity,
                            unit: NSLocalizedString(
                                SettingsManager.shared.precipitationIntensityUnit.key,
                                comment: ""
                            )
                        )
                    )
                }
                if let precipitationProb = self.weather.dailyForecasts[index].day.precipitationProbability {
                    DailyValueItem(
                        title: NSLocalizedString("precipitation_probability", comment: ""),
                        content: getPercentText(precipitationProb, decimal: 1)
                    )
                }
                DailyValueItem(
                    title: NSLocalizedString("wind", comment: ""),
                    content: getWindText(
                        wind: self.weather.dailyForecasts[index].day.wind,
                        unit: SettingsManager.shared.speedUnit
                    )
                )
            }
            
            Section(
                header: DailySectionTitle(key: "nighttime")
            ) {
                HalfDayHeader(
                    halfDay: self.weather.dailyForecasts[index].night,
                    daylight: false
                )
                
                if let precipitationTotal = self.weather.dailyForecasts[index].night.precipitationTotal {
                    DailyValueItem(
                        title: NSLocalizedString("precipitation", comment: ""),
                        content: SettingsManager.shared.precipitationUnit.formatValueWithUnit(
                            precipitationTotal,
                            unit: NSLocalizedString(
                                SettingsManager.shared.precipitationUnit.key,
                                comment: ""
                            )
                        )
                    )
                }
                if let precipitationIntensity = self.weather.dailyForecasts[index].night.precipitationIntensity {
                    DailyValueItem(
                        title: NSLocalizedString("precipitation_intensity", comment: ""),
                        content: SettingsManager.shared.precipitationIntensityUnit.formatValueWithUnit(
                            precipitationIntensity,
                            unit: NSLocalizedString(
                                SettingsManager.shared.precipitationIntensityUnit.key,
                                comment: ""
                            )
                        )
                    )
                }
                if let precipitationProb = self.weather.dailyForecasts[index].night.precipitationProbability {
                    DailyValueItem(
                        title: NSLocalizedString("precipitation_probability", comment: ""),
                        content: getPercentText(precipitationProb, decimal: 1)
                    )
                }
                DailyValueItem(
                    title: NSLocalizedString("wind", comment: ""),
                    content: getWindText(
                        wind: self.weather.dailyForecasts[index].night.wind,
                        unit: SettingsManager.shared.speedUnit
                    )
                )
            }
        }.listStyle(
            GroupedListStyle()
        ).background(
            Color.clear
        )
    }
}

struct DailySectionTitle: View {
    
    let key: String
    
    var body: some View {
        Text(
            NSLocalizedString(key, comment: "")
        ).font(
            Font(bodyFont)
        ).foregroundColor(
            Color(UIColor.secondaryLabel)
        )
    }
}

struct HalfDayHeader: View {
    
    let halfDay: HalfDay
    let daylight: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: littleMargin) {
            Image(
                uiImage: UIImage.getWeatherIcon(
                    weatherCode: halfDay.weatherCode,
                    daylight: daylight
                )!.scaleToSize(
                    CGSize(width: 56, height: 56)
                )!
            ).frame(
                width: 56,
                height: 56,
                alignment: .center
            )
            
            Text(
                halfDay.weatherPhase
                + ", "
                + SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                    halfDay.temperature.temperature,
                    unit: NSLocalizedString(
                        SettingsManager.shared.temperatureUnit.key,
                        comment: ""
                    )
                )
            ).font(
                Font(titleFont)
            ).foregroundColor(
                Color(UIColor.label)
            )
        }.padding()
    }
}

struct DailyValueItem: View {
    
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(
                self.title
            ).font(
                Font(titleFont)
            ).foregroundColor(
                Color(UIColor.label)
            )
            
            Text(
                self.content
            ).font(
                Font(bodyFont)
            ).foregroundColor(
                Color(UIColor.secondaryLabel)
            )
        }.padding(
            EdgeInsets(
                top: littleMargin,
                leading: littleMargin,
                bottom: littleMargin,
                trailing: littleMargin
            )
        )
    }
}

