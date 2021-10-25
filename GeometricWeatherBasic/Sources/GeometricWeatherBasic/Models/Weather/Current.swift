//
//  Current.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/12.
//

import Foundation

public struct Current: Codable {
    
    public let weatherText: String
    public let weatherCode: WeatherCode
    
    public let temperature: Temperature
    public let precipitationIntensity: Double?
    public let precipitationProbability: Double?
    public let wind: Wind
    public let uv: UV
    public let airQuality: AirQuality
    
    public let relativeHumidity: Double?
    public let pressure: Double?
    public let visibility: Double?
    public let dewPoint: Int?
    public let cloudCover: Int?
    public let ceiling: Int?
    
    public let dailyForecast: String?
    public let hourlyForecast: String?
    
    public init(
        weatherText: String,
        weatherCode: WeatherCode,
        temperature: Temperature,
        precipitationIntensity: Double?,
        precipitationProbability: Double?,
        wind: Wind,
        uv: UV,
        airQuality: AirQuality,
        relativeHumidity: Double?,
        pressure: Double?,
        visibility: Double?,
        dewPoint: Int?,
        cloudCover: Int?,
        ceiling: Int?,
        dailyForecast: String?,
        hourlyForecast: String?
    ) {
        self.weatherText = weatherText
        self.weatherCode = weatherCode
        self.temperature = temperature
        self.precipitationIntensity = precipitationIntensity
        self.precipitationProbability = precipitationProbability
        self.wind = wind
        self.uv = uv
        self.airQuality = airQuality
        self.relativeHumidity = relativeHumidity
        self.pressure = pressure
        self.visibility = visibility
        self.dewPoint = dewPoint
        self.cloudCover = cloudCover
        self.ceiling = ceiling
        self.dailyForecast = dailyForecast
        self.hourlyForecast = hourlyForecast
    }

}
