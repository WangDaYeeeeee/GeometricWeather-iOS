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
    public let precipitationTotal: Double?
    public let precipitationIntensity: Double?
    public let precipitationProbability: Double?
    public let wind: Wind?
    
    public let cloudCover: Int?
    public let pressure: Double?
    public let visibility: Double?
    public let humidity: Double?
    
    public init(
        weatherText: String,
        weatherPhase: String,
        weatherCode: WeatherCode,
        temperature: Temperature,
        precipitationTotal: Double?,
        precipitationIntensity: Double?,
        precipitationProbability: Double?,
        wind: Wind?,
        cloudCover: Int?,
        pressure: Double?,
        visibility: Double?,
        humidity: Double?
    ) {
        self.weatherText = weatherText
        self.weatherPhase = weatherPhase
        self.weatherCode = weatherCode
        self.temperature = temperature
        self.precipitationTotal = precipitationTotal
        self.precipitationIntensity = precipitationIntensity
        self.precipitationProbability = precipitationProbability
        self.wind = wind
        self.cloudCover = cloudCover
        self.pressure = pressure
        self.visibility = visibility
        self.humidity = humidity
    }
    
}
