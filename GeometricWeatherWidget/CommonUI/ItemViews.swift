//
//  ItemView.swift
//  WeatherWidgetExtension
//
//  Created by 王大爷 on 2021/9/20.
//

import SwiftUI
import GeometricWeatherBasic

private let font = UIFont.systemFont(
    ofSize: miniCaptionFont.pointSize,
    weight: .bold
)

// MARK: - daily.

struct DailyItemView: View {
    
    let weather: Weather
    let timezone: TimeZone
    let index: Int
    let total: Int
    let temperatureRange: (min: Int, max: Int)
    
    var body: some View {
        VStack(alignment: .center, spacing: 2.0) {
            Text(
                self.weather.dailyForecasts[index].isToday(timezone: self.timezone)
                ? getLocalizedText("today")
                : getWeekText(
                    week: self.weather.dailyForecasts[index].getWeek(
                        timezone: self.timezone
                    )
                )
            ).font(
                Font(miniCaptionFont).weight(.bold)
            ).foregroundColor(
                .white
            )
            
            if let uiImage = UIImage.getWeatherIcon(
                weatherCode: self.weather.dailyForecasts[index].day.weatherCode,
                daylight: true
            )?.scaleToSize(
                CGSize(width: normalWeatherIconSize, height: normalWeatherIconSize)
            ) {
                Image(uiImage: uiImage).padding(
                    .bottom, 2.0
                )
            }
            
            MiddleUnitText(
                value: SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                    self.weather.dailyForecasts[index].day.temperature.temperature,
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
                                y: proxy.size.height - 6.0 - self.getTemperaturePercent(
                                    self.weather.dailyForecasts[
                                        index
                                    ].day.temperature.temperature
                                ) * (
                                    proxy.size.height - 12.0
                                )
                            )
                        )
                        path.addLine(
                            to: CGPoint(
                                x: proxy.size.width * 0.5,
                                y: proxy.size.height - 6.0 - self.getTemperaturePercent(
                                    self.weather.dailyForecasts[
                                        index
                                    ].night.temperature.temperature
                                ) * (
                                    proxy.size.height - 12.0
                                )
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
                    self.weather.dailyForecasts[index].night.temperature.temperature,
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

            if let uiImage = UIImage.getWeatherIcon(
                weatherCode: self.weather.dailyForecasts[index].night.weatherCode,
                daylight: false
            )?.scaleToSize(
                CGSize(width: normalWeatherIconSize, height: normalWeatherIconSize)
            ) {
                Image(uiImage: uiImage)
            }
        }
    }
    
    private func getTemperaturePercent(_ temperature: Int) -> Double {
        return Double(
            temperature - self.temperatureRange.min
        ) / Double(
            self.temperatureRange.max - self.temperatureRange.min
        )
    }
    
    private func getTemperatureGradient(
        forDaytime day: Int,
        andNighttime night: Int
    ) -> LinearGradient {
        return LinearGradient(
            colors: [
                Color(colorLevel6),
                Color(colorLevel5),
                Color(colorLevel4),
                Color(colorLevel3),
                Color(colorLevel2),
                Color(colorLevel1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - hourly.

struct HourlyItemView: View {
    
    let weather: Weather
    let timezone: TimeZone
    let index: Int
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 2.0) {
                Text(
                    getHourText(
                        hour: self.weather.hourlyForecasts[index].getHour(
                            isTwelveHour(),
                            timezone: self.timezone
                        )
                    )
                ).font(
                    Font(miniCaptionFont).weight(.bold)
                ).foregroundColor(
                    .white
                )
                
                if let uiImage = UIImage.getWeatherIcon(
                    weatherCode: self.weather.hourlyForecasts[index].weatherCode,
                    daylight: self.weather.hourlyForecasts[index].daylight
                )?.scaleToSize(
                    CGSize(width: normalWeatherIconSize, height: normalWeatherIconSize)
                ) {
                    Image(uiImage: uiImage)
                }
                
                MiddleUnitText(
                    value: SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                        self.weather.hourlyForecasts[index].temperature.temperature,
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
