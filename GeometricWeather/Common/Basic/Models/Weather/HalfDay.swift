//
//  HalfDay.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

struct HalfDay: Codable {
    
    let weatherText: String
    let weatherPhase: String
    let weatherCode: WeatherCode
    
    let temperature: Temperature
    let precipitation: Precipitation
    let precipitationProbability: Double?
    let wind: Wind
    
    let cloudCover: Int?
    
    init(
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
