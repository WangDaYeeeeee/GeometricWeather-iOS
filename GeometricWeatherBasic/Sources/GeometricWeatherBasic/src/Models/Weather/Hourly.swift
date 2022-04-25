//
//  Hourly.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/14.
//

import Foundation

public struct Hourly: Codable {
    
    // local time.
    public let time: TimeInterval
    public let daylight: Bool
    
    public let weatherText: String
    public let weatherCode: WeatherCode
    
    public let temperature: Temperature
    public let precipitationIntensity: Double?
    public let precipitationProbability: Double?
    public let wind: Wind?
    
    public init(
        time: TimeInterval,
        daylight: Bool,
        weatherText: String,
        weatherCode: WeatherCode,
        temperature: Temperature,
        precipitationIntensity: Double?,
        precipitationProbability: Double?,
        wind: Wind? = nil
    ) {
        self.time = time
        self.daylight = daylight
        self.weatherText = weatherText
        self.weatherCode = weatherCode
        self.temperature = temperature
        self.precipitationIntensity = precipitationIntensity
        self.precipitationProbability = precipitationProbability
        self.wind = wind
    }

    public func getHour(_ twelveHour: Bool, timezone: TimeZone) -> Int {
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
    
    public func formatDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: Date(timeIntervalSince1970: time))
    }
}
