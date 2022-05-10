//
//  DailyView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2021/10/8.
//

import SwiftUI
import WidgetKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings

private let verticalItemCount = 6
private let horizontalItemCount = 4

// MARK: - daily view.

struct DailyView: View {
    
    let location: Location
    let temperatureRange: (min: Int, max: Int)
        
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
        for i in 1 ..< verticalItemCount {
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
                ForEach(0 ..< verticalItemCount, id: \.self) { i in
                    DailyItemView(
                        weather: weather,
                        timezone: self.location.timezone,
                        index: i,
                        total: verticalItemCount,
                        temperatureRange: self.temperatureRange
                    )
                }
            }
        } else {
            Color.clear
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
                    timezone: self.location.timezone
                )
                
                // night icon.
                VerticalIconView(
                    weather: weather,
                    daytime: false
                ).padding(.trailing, 4.0)
                
                // night temperature.
                VerticalTemperatureView(
                    weather: weather,
                    daytime: false
                )
                
                // histogram.
                VerticalHistogramView(
                    weather: weather,
                    timeZone: self.location.timezone,
                    temperatureRange: self.temperatureRange
                )
                
                // day temperature.
                VerticalTemperatureView(
                    weather: weather,
                    daytime: true
                )

                // day icon.
                VerticalIconView(
                    weather: weather,
                    daytime: true
                ).padding(.leading, 4.0)
            }
        } else {
            Color.cyan
        }
    }
}

// MARK: - vertical week name view.

private struct VerticalWeekNameView: View {
    
    let hours: [String]
    
    init(hours: [String]) {
        self.hours = hours
    }
    
    init(
        weather: Weather,
        timezone: TimeZone
    ) {
        var hours = [String]()
        for i in 0 ..< horizontalItemCount {
            hours.append(
                getWeekText(
                    week: weather.dailyForecasts[i].getWeek(timezone: timezone)
                )
            )
        }
        self.hours = hours
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(self.hours.indices, id: \.self) { i in
                VStack {
                    Spacer()
                    Text(self.hours[i])
                        .font(Font(miniCaptionFont).weight(.bold))
                        .foregroundColor(.white)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - vertical icon view.

private struct VerticalIconView: View {
    
    let weatherCodes: [WeatherCode]
    let daytime: Bool
    
    init(
        weatherCodes: [WeatherCode],
        daytime: Bool
    ) {
        self.weatherCodes = weatherCodes
        self.daytime = daytime
    }
    
    init(
        weather: Weather,
        daytime: Bool
    ) {
        var weatherCodes = [WeatherCode]()
        for i in 0 ..< horizontalItemCount {
            weatherCodes.append(
                daytime
                ? weather.dailyForecasts[i].day.weatherCode
                : weather.dailyForecasts[i].night.weatherCode
            )
        }
        self.weatherCodes = weatherCodes
        
        self.daytime = daytime
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(self.weatherCodes.indices, id: \.self) { i in
                VStack {
                    Spacer()
                    Image.getWeatherIcon(
                        weatherCode: self.weatherCodes[i],
                        daylight: self.daytime
                    )?.resizable()
                        .frame(width: miniWeatherIconSize, height: miniWeatherIconSize)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - vertical temperature view.

private struct VerticalTemperatureView: View {
    
    let temperatures: [Int]
    let daytime: Bool
    
    init(
        temperatures: [Int],
        daytime: Bool
    ) {
        self.temperatures = temperatures
        self.daytime = daytime
    }
    
    init(
        weather: Weather,
        daytime: Bool
    ) {
        var temperatures = [Int]()
        for i in 0 ..< horizontalItemCount {
            temperatures.append(
                daytime
                ? weather.dailyForecasts[i].day.temperature.temperature
                : weather.dailyForecasts[i].night.temperature.temperature
            )
        }
        self.temperatures = temperatures
        
        self.daytime = daytime
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            ForEach(self.temperatures.indices, id: \.self) { i in
                VStack {
                    Spacer()
                    Text(
                        SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                            self.temperatures[i],
                            unit: "°"
                        )
                    ).font(Font(miniCaptionFont).weight(.bold))
                        .foregroundColor(.white)
                        .opacity(self.daytime ? 1.0 : secondaryTextOpacity)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - vertical histogram view.

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

private struct VerticalHistogramView: View {
    
    let dayValues: [Double] // 0 - 1.
    let nightValues: [Double] // 0 - 1.
    
    init(
        dayValues: [Double],
        nightValues: [Double]
    ) {
        self.dayValues = dayValues
        self.nightValues = nightValues
    }
    
    init(
        weather: Weather,
        timeZone: TimeZone,
        temperatureRange: (min: Int, max: Int)
    ) {
        var dayValues = [Double]()
        var nightValues = [Double]()
        for i in 0 ..< horizontalItemCount {
            dayValues.append(
                getTemperatureValue(
                    weather.dailyForecasts[i].day.temperature.temperature,
                    in: temperatureRange
                )
            )
            nightValues.append(
                getTemperatureValue(
                    weather.dailyForecasts[i].night.temperature.temperature,
                    in: temperatureRange
                )
            )
        }
        
        self.dayValues = dayValues
        self.nightValues = nightValues
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(self.dayValues.indices, id: \.self) { i in
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
                                    x: 6.0
                                    + self.nightValues[i] * (proxy.size.width - 12.0),
                                    y: proxy.size.height * 0.5
                                )
                            )
                            path.addLine(
                                to: CGPoint(
                                    x: 6.0
                                    + self.dayValues[i] * (proxy.size.width - 12.0),
                                    y: proxy.size.height * 0.5
                                )
                            )
                        }.stroke(
                            histogramForeground,
                            style: StrokeStyle(lineWidth: 6.0, lineCap: .round)
                        ).shadow(
                            color: histogramShadowColor,
                            radius: horizontalHistogramShadowRadius,
                            x: horizontalHistogramShadowOffsetX,
                            y: horizontalHistogramShadowOffsetY
                        )
                    }
                }.frame(height: 6.0 + 2.0 * 2)
                
                Spacer()
            }
        }
    }
}

struct DailyView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(0 ..< verticalItemCount, id: \.self) { i in
                DailyItemView(
                    weekText: "week1",
                    dayWeatherCode: .clear,
                    dayTemperature: 8,
                    dayValue: 0.8,
                    nightWeatherCode: .rain(.heavy),
                    nightTemperature: -9,
                    nightValue: 0.3
                )
            }
        }.background(
            Color.cyan
        ).previewContext(
            WidgetPreviewContext(family: .systemMedium)
        )
        
        HStack(alignment: .center, spacing: 0) {
            // week name.
            VerticalWeekNameView(
                hours: ["hour1", "hour1", "hour1", "hour1"]
            )
            
            // night icon.
            VerticalIconView(
                weatherCodes: [.clear, .clear, .clear, .clear],
                daytime: false
            ).padding(.trailing, 4.0)
            
            // night temperature.
            VerticalTemperatureView(
                temperatures: [7, 7, 9, 8],
                daytime: false
            )
            
            // histogram.
            VerticalHistogramView(
                dayValues: [0.2, 0.2, 0.2, 0.2],
                nightValues: [0.8, 0.8, 0.8, 0.8]
            )
            
            // day temperature.
            VerticalTemperatureView(
                temperatures: [7, 7, 9, 8],
                daytime: true
            )

            // day icon.
            VerticalIconView(
                weatherCodes: [.clear, .clear, .clear, .clear],
                daytime: true
            ).padding(.leading, 4.0)
        }.background(
            Color.cyan
        ).previewContext(
            WidgetPreviewContext(family: .systemSmall)
        )
    }
}

