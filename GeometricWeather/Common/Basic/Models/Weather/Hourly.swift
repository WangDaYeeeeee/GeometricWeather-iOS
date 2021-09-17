//
//  Hourly.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/14.
//

import Foundation

struct Hourly: Codable {
    
    let time: TimeInterval
    let daylight: Bool
    
    let weatherText: String
    let weatherCode: WeatherCode
    
    let temperature: Temperature
    let precipitation: Precipitation
    let precipitationProbability: Double?
    
    init(
        time: TimeInterval,
        daylight: Bool,
        weatherText: String,
        weatherCode: WeatherCode,
        temperature: Temperature,
        precipitation: Precipitation,
        precipitationProbability: Double?
    ) {
        self.time = time
        self.daylight = daylight
        self.weatherText = weatherText
        self.weatherCode = weatherCode
        self.temperature = temperature
        self.precipitation = precipitation
        self.precipitationProbability = precipitationProbability
    }

    func getHour(_ twelveHour: Bool, timezone: TimeZone) -> Int {
        var hour = Calendar.current.component(
            .hour,
            from: Date(timeIntervalSince1970: time)
        )
        if (twelveHour) {
            hour %= 12
            if (hour == 0) {
                hour = 12;
            }
        }
        return hour
    }
    
    func formateDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: Date(timeIntervalSince1970: time))
    }
}
