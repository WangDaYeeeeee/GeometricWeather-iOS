//
//  ItemView.swift
//  WeatherWidgetExtension
//
//  Created by 王大爷 on 2021/9/20.
//

import SwiftUI
import WidgetKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings

// MARK: - daily.

private func getTemperatureValue(
    _ temperature: Int,
    in temperatureRange: (min: Int, max: Int)
) -> Double {
    return Double(
        temperature - temperatureRange.min
    ) / Double(
        temperatureRange.max - temperatureRange.min
    )
}

struct DailyItemView: View {
    
    let weekText: String
    
    let dayWeatherCode: WeatherCode
    let dayTemperature: Int
    let dayValue: Double // 0 - 1.
    
    let nightWeatherCode: WeatherCode
    let nightTemperature: Int
    let nightValue: Double // 0 - 1.
    
    init(
        weekText: String,
        dayWeatherCode: WeatherCode,
        dayTemperature: Int,
        dayValue: Double, // 0 - 1.
        nightWeatherCode: WeatherCode,
        nightTemperature: Int,
        nightValue: Double // 0 - 1.
    ) {
        self.weekText = weekText
        self.dayWeatherCode = dayWeatherCode
        self.dayTemperature = dayTemperature
        self.dayValue = dayValue
        self.nightWeatherCode = nightWeatherCode
        self.nightTemperature = nightTemperature
        self.nightValue = nightValue
    }
    
    init(
        weather: Weather,
        timezone: TimeZone,
        index: Int,
        total: Int,
        temperatureRange: (min: Int, max: Int)
    ) {
        self.weekText = weather.dailyForecasts[index].isToday(timezone: timezone)
        ? getLocalizedText("today")
        : getWeekText(weather.dailyForecasts[index])
        
        self.dayWeatherCode = weather.dailyForecasts[index].day.weatherCode
        self.dayTemperature = weather.dailyForecasts[index].day.temperature.temperature
        self.dayValue = getTemperatureValue(
            weather.dailyForecasts[index].day.temperature.temperature,
            in: temperatureRange
        )
        
        self.nightWeatherCode = weather.dailyForecasts[index].night.weatherCode
        self.nightTemperature = weather.dailyForecasts[index].night.temperature.temperature
        self.nightValue = getTemperatureValue(
            weather.dailyForecasts[index].night.temperature.temperature,
            in: temperatureRange
        )
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 2.0) {
            Text(self.weekText)
                .font(Font(miniCaptionFont).weight(.bold))
                .foregroundColor(.white)
            
            
            UIImage.getWeatherIcon(
                weatherCode: self.dayWeatherCode,
                daylight: true
            )?.resize(
                to: CGSize(width: normalWeatherIconSize, height: normalWeatherIconSize)
            )?.toImage()
                .padding(.bottom, 2.0)
            
            MiddleUnitText(
                value: SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                    self.dayTemperature,
                    unit: ""
                ),
                unit: "°",
                font: Font(miniCaptionFont).weight(.bold),
                textColor: .white
            )
            
            GeometryReader { proxy in
                ZStack {
                    Path { path in
                        path.move(
                            to: CGPoint(
                                x: proxy.size.width * 0.5,
                                y: 6.0
                            )
                        )
                        path.addLine(
                            to: CGPoint(
                                x: proxy.size.width * 0.5,
                                y: proxy.size.height - 6.0
                            )
                        )
                    }.stroke(
                        histogramBackground,
                        style: StrokeStyle(lineWidth: 6.0, lineCap: .round)
                    )
                    
                    Path { path in
                        path.move(
                            to: CGPoint(
                                x: proxy.size.width * 0.5,
                                y: proxy.size.height
                                - 6.0
                                - self.dayValue * (proxy.size.height - 12.0)
                            )
                        )
                        path.addLine(
                            to: CGPoint(
                                x: proxy.size.width * 0.5,
                                y: proxy.size.height
                                - 6.0
                                - self.nightValue * (proxy.size.height - 12.0)
                            )
                        )
                    }.stroke(
                        histogramForeground,
                        style: StrokeStyle(lineWidth: 6.0, lineCap: .round)
                    ).shadow(
                        color: histogramShadowColor,
                        radius: verticalHistogramShadowRadius,
                        x: verticalHistogramShadowOffsetX,
                        y: verticalHistogramShadowOffsetY
                    )
                }
            }
            
            MiddleUnitText(
                value: SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                    self.nightTemperature,
                    unit: ""
                ),
                unit: "°",
                font: Font(miniCaptionFont).weight(.bold),
                textColor: .white
            ).opacity(
                secondaryTextOpacity
            ).padding(
                .bottom, 2.0
            )
            
            UIImage.getWeatherIcon(
                weatherCode: self.nightWeatherCode,
                daylight: false
            )?.resize(
                to: CGSize(width: normalWeatherIconSize, height: normalWeatherIconSize)
            )?.toImage()
        }
    }
}

// MARK: - hourly.

struct HourlyItemView: View {
    
    let hourText: String
    let weatherCode: WeatherCode
    let daylight: Bool
    let temperature: Int
    
    init(
        hourText: String,
        weatherCode: WeatherCode,
        daylight: Bool,
        temperature: Int
    ) {
        self.hourText = hourText
        self.weatherCode = weatherCode
        self.daylight = daylight
        self.temperature = temperature
    }
    
    init(
        weather: Weather,
        timezone: TimeZone,
        index: Int
    ) {
        self.hourText = getHourText(weather.hourlyForecasts[index])
        self.weatherCode = weather.hourlyForecasts[index].weatherCode
        self.daylight = weather.hourlyForecasts[index].daylight
        self.temperature = weather.hourlyForecasts[index].temperature.temperature
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 2.0) {
                Text(self.hourText)
                    .font(Font(miniCaptionFont).weight(.bold))
                    .foregroundColor(.white)
                
                UIImage.getWeatherIcon(
                    weatherCode: self.weatherCode,
                    daylight: self.daylight
                )?.resize(
                    to: CGSize(width: normalWeatherIconSize, height: normalWeatherIconSize)
                )?.toImage()
                
                MiddleUnitText(
                    value: SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                        self.temperature,
                        unit: ""
                    ),
                    unit: "°",
                    font: Font(miniCaptionFont).weight(.bold),
                    textColor: .white
                ).foregroundColor(
                    .white
                )
            }
            
            Spacer()
        }
    }
}

struct ItemViews_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            DailyItemView(
                weekText: "week1",
                dayWeatherCode: .clear,
                dayTemperature: 8,
                dayValue: 0.8,
                nightWeatherCode: .rain(.heavy),
                nightTemperature: -9,
                nightValue: 0.3
            )
            Spacer()
            HourlyItemView(
                hourText: "hour1",
                weatherCode: .clear,
                daylight: false,
                temperature: 6
            )
        }.background(
            Color.cyan
        ).previewContext(
            WidgetPreviewContext(family: .systemSmall)
        )
    }
}
