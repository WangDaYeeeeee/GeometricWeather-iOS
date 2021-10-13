//
//  DailyView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2021/10/8.
//

import SwiftUI
import GeometricWeatherBasic

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
            HStack(alignment: .center) {
                Spacer()

                ForEach(0 ..< 2 * itemCount - 1) { i in
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
            VStack(alignment: .center) {
                Spacer()

                ForEach(0 ..< 2 * itemCount - 1) { i in
                    if i % 2 != 0 {
                        Spacer()
                    } else {
                        HorizontalDailyItemView(
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
