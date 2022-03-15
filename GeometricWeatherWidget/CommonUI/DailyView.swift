//
//  DailyView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2021/10/8.
//

import SwiftUI
import GeometricWeatherBasic

// MARK: - daily view.

struct DailyView: View {
    
    let location: Location
    let temperatureRange: (min: Int, max: Int)
    
    let itemCount = 6
    
    init(location: Location) {
        self.location = location
        
        guard let weather = location.weather else {
            self.temperatureRange = (0, 0)
            return
        }
        
        var range = (
            min: weather.dailyForecasts[0].night.temperature.temperature,
            max: weather.dailyForecasts[0].day.temperature.temperature
        )
        for i in 1 ..< itemCount {
            if range.min > weather.dailyForecasts[i].night.temperature.temperature {
                range.min = weather.dailyForecasts[i].night.temperature.temperature
            }
            if range.max < weather.dailyForecasts[i].day.temperature.temperature {
                range.max = weather.dailyForecasts[i].day.temperature.temperature
            }
        }
        self.temperatureRange = range
    }
    
    var body: some View {
        if let weather = self.location.weather {
            HStack(alignment: .center, spacing: 0) {
                ForEach(0 ..< self.itemCount) { i in
                    DailyItemView(
                        weather: weather,
                        timezone: self.location.timezone,
                        index: i,
                        total: self.itemCount,
                        temperatureRange: self.temperatureRange
                    )
                }
            }
        } else {
            HStack(alignment: .center) {
                Spacer()

                ForEach(0 ..< self.itemCount) { i in
                    if i % 2 != 0 {
                        Spacer()
                    } else {
                        Text(
                            "--"
                        ).font(
                            Font(miniCaptionFont)
                        ).foregroundColor(
                            .white
                        )
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - horizontal daily view.

struct HorizontalDailyView: View {
    
    let location: Location
    let temperatureRange: (min: Int, max: Int)
    
    let itemCount = 4
    
    init(location: Location) {
        self.location = location
        
        guard let weather = location.weather else {
            self.temperatureRange = (0, 0)
            return
        }
        
        var range = (
            min: weather.dailyForecasts[0].night.temperature.temperature,
            max: weather.dailyForecasts[0].day.temperature.temperature
        )
        for i in 1 ..< itemCount {
            if range.min > weather.dailyForecasts[i].night.temperature.temperature {
                range.min = weather.dailyForecasts[i].night.temperature.temperature
            }
            if range.max < weather.dailyForecasts[i].day.temperature.temperature {
                range.max = weather.dailyForecasts[i].day.temperature.temperature
            }
        }
        self.temperatureRange = range
    }
    
    var body: some View {
        if let weather = self.location.weather {
            HStack(alignment: .center, spacing: 0) {
                // week name.
                VerticalWeekNameView(
                    weather: weather,
                    timezone: self.location.timezone,
                    itemCount: self.itemCount
                )
                
                // night icon.
                VerticalIconView(
                    weather: weather,
                    itemCount: self.itemCount,
                    daytime: false
                ).padding(.trailing, 4.0)
                
                // night temperature.
                VerticalTemperatureView(
                    weather: weather,
                    itemCount: self.itemCount,
                    daytime: false
                )
                
                // histogram.
                VerticalHistogramView(
                    weather: weather,
                    itemCount: self.itemCount,
                    temperatureRange: self.temperatureRange
                )
                
                // day temperature.
                VerticalTemperatureView(
                    weather: weather,
                    itemCount: self.itemCount,
                    daytime: true
                )

                // day icon.
                VerticalIconView(
                    weather: weather,
                    itemCount: self.itemCount,
                    daytime: true
                ).padding(.leading, 4.0)
            }
        } else {
            VStack(alignment: .center) {
                Spacer()

                ForEach(0 ..< 2 * itemCount - 1) { i in
                    if i % 2 != 0 {
                        Spacer()
                    } else {
                        Text(
                            "--"
                        ).font(
                            Font(miniCaptionFont)
                        ).foregroundColor(
                            .white
                        )
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - vertical week name view.

private struct VerticalWeekNameView: View {
    
    let weather: Weather
    let timezone: TimeZone
    let itemCount: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0 ..< self.itemCount) { i in
                VStack {
                    Spacer()
                    
                    Text(
                        getWeekText(
                            week: self.weather.dailyForecasts[i].getWeek(
                                timezone: self.timezone
                            )
                        )
                    ).font(
                        Font(miniCaptionFont).weight(.bold)
                    ).foregroundColor(
                        .white
                    )
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - vertical icon view.

private struct VerticalIconView: View {
    
    let weather: Weather
    let itemCount: Int
    let daytime: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0 ..< self.itemCount) { i in
                VStack {
                    Spacer()
                    
                    if let uiImage = UIImage.getWeatherIcon(
                        weatherCode: self.daytime
                        ? self.weather.dailyForecasts[i].day.weatherCode
                        : self.weather.dailyForecasts[i].night.weatherCode,
                        daylight: self.daytime
                    )?.scaleToSize(
                        CGSize(width: miniWeatherIconSize, height: miniWeatherIconSize)
                    ) {
                        Image(uiImage: uiImage)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - vertical temperature view.

private struct VerticalTemperatureView: View {
    
    let weather: Weather
    let itemCount: Int
    let daytime: Bool
    
    var body: some View {
        VStack(alignment: .trailing) {
            ForEach(0 ..< self.itemCount) { i in
                VStack {
                    Spacer()
                    
                    Text(
                        SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                            self.daytime
                            ? self.weather.dailyForecasts[i].day.temperature.temperature
                            : self.weather.dailyForecasts[i].night.temperature.temperature,
                            unit: "°"
                        )
                    ).font(
                        Font(miniCaptionFont).weight(.bold)
                    ).foregroundColor(
                        .white
                    ).opacity(
                        self.daytime ? 1.0 : secondaryTextOpacity
                    )
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - vertical histogram view.

private struct VerticalHistogramView: View {
    
    let weather: Weather
    let itemCount: Int
    let temperatureRange: (min: Int, max: Int)
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0 ..< self.itemCount) { i in
                Spacer()
                
                GeometryReader { proxy in
                    ZStack {
                        Path { path in
                            path.move(
                                to: CGPoint(
                                    x: 6.0,
                                    y: proxy.size.height * 0.5
                                )
                            )
                            path.addLine(
                                to: CGPoint(
                                    x: proxy.size.width - 6.0,
                                    y: proxy.size.height * 0.5
                                )
                            )
                        }.stroke(
                            histogramBackground,
                            style: StrokeStyle(lineWidth: 6.0, lineCap: .round)
                        )
                        
                        Path { path in
                            path.move(
                                to: CGPoint(
                                    x: 6.0 + self.getTemperaturePercent(
                                        self.weather.dailyForecasts[
                                            i
                                        ].night.temperature.temperature
                                    ) * (
                                        proxy.size.width - 12.0
                                    ),
                                    y: proxy.size.height * 0.5
                                )
                            )
                            path.addLine(
                                to: CGPoint(
                                    x: 6.0 + self.getTemperaturePercent(
                                        self.weather.dailyForecasts[
                                            i
                                        ].day.temperature.temperature
                                    ) * (
                                        proxy.size.width - 12.0
                                    ),
                                    y: proxy.size.height * 0.5
                                )
                            )
                        }.stroke(
                            histogramForeground,
                            style: StrokeStyle(lineWidth: 6.0, lineCap: .round)
                        )
                    }
                }.frame(height: 6.0 + 2.0 * 2)
                
                Spacer()
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
}
