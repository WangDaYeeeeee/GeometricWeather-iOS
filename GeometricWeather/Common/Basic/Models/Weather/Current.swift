//
//  Current.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/12.
//

import Foundation

struct Current: Codable {
    
    let weatherText: String
    let weatherCode: WeatherCode
    
    let temperature: Temperature
    let precipitation: Precipitation
    let precipitationProbability: Double
    let wind: Wind
    let uv: UV
    let airQuality: AirQuality
    
    let relativeHumidity: Double?
    let pressure: Double?
    let visibility: Double?
    let dewPoint: Int?
    let cloudCover: Int?
    let ceiling: Int?
    
    let dailyForecast: String?
    let hourlyForecast: String?
    
    init(
        weatherText: String,
        weatherCode: WeatherCode,
        temperature: Temperature,
        precipitation: Precipitation,
        precipitationProbability: Double,
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
        self.precipitation = precipitation
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
