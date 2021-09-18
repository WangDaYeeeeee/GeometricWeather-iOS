//
//  HalfDay.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct HalfDay: Codable {
    
    public let weatherText: String
    public let weatherPhase: String
    public let weatherCode: WeatherCode
    
    public let temperature: Temperature
    public let precipitation: Precipitation
    public let precipitationProbability: Double?
    public let wind: Wind
    
    public let cloudCover: Int?
    
    public init(
        weatherText: String,
        weatherPhase: String,
        weatherCode: WeatherCode,
        temperature: Temperature,
        precipitation: Precipitation,
        precipitationProbability: Double?,
        wind: Wind,
        cloudCover: Int?
    ) {
        self.weatherText = weatherText
        self.weatherPhase = weatherPhase
        self.weatherCode = weatherCode
        self.temperature = temperature
        self.precipitation = precipitation
        self.precipitationProbability = precipitationProbability
        self.wind = wind
        self.cloudCover = cloudCover
    }
    
}
