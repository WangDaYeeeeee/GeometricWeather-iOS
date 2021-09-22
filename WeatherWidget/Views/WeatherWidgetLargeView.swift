//
//  WeatherWidgetLargeView.swift
//  WeatherWidgetExtension
//
//  Created by 王大爷 on 2021/9/19.
//

import WidgetKit
import SwiftUI
import GeometricWeatherBasic

// MARK: - view.

struct WeatherWidgetLargeView: View {
    
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            WeatherWidgetMediumHeaderView(
                location: self.location
            ).padding(
                [.top, .leading, .trailing]
            )
            
            if !(self.location.weather?.alerts.isEmpty ?? true) {
                Color.white.opacity(0.0).frame(width: 1.0, height: 4.0, alignment: .center)
                Text(
                    self.location.weather!.alerts[0].description
                ).font(
                    Font(miniCaptionFont)
                ).foregroundColor(
                    .white
                ).padding(
                    [.leading, .trailing]
                )
                Color.white.opacity(0.0).frame(width: 1.0, height: 4.0, alignment: .center)
            }
            
            Color.white.opacity(0.0).frame(width: 1.0, height: 12.0, alignment: .center)
            WeatherWidgetLargeDailyView(
                location: self.location
            )
            
            Color.white.opacity(0.0).frame(width: 1.0, height: 18.0, alignment: .center)
            WeatherWidgetMediumHourlyView(
                location: self.location
            ).padding(
                [.bottom, .leading, .trailing]
            )
        }
    }
}

struct WeatherWidgetLargeDailyView: View {
    
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
        for i in 1 ..< 6 {
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
            HStack(alignment: .center) {
                Spacer()
                // show 6 daily items.
                ForEach(0 ..< 2 * 6 - 1) { i in
                    if i % 2 != 0 {
                        Spacer()
                    } else {
                        DailyItemView(
                            weather: weather,
                            timezone: self.location.timezone,
                            index: i / 2,
                            temperatureRagne: self.temperatureRange
                        )
                    }
                }
                Spacer()
            }
        } else {
            HStack(alignment: .center) {
                Spacer()
                // show 6 daily items.
                ForEach(0 ..< 2 * 6 - 1) { i in
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

// MARK: - preview.

struct WeatherWidgetLargeView_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack {
            Color.black
            
            WeatherWidgetLargeView(
                location: .buildDefaultLocation(
                    weatherSource: WeatherSource[0],
                    residentPosition: false
                )
            )
        }.previewContext(
            WidgetPreviewContext(family: .systemLarge)
        )
    }
}
