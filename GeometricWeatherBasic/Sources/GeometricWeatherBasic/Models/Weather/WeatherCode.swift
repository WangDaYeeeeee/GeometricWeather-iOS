//
//  WeatherCode.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public enum WeatherCode: Codable {
    
    case clear
    case partlyCloudy
    case cloudy
    case rain(PrecipitationLevel)
    case snow(PrecipitationLevel)
    case sleet(PrecipitationLevel)
    case wind
    case fog
    case haze
    case hail
    case thunder
    case thunderstorm
}

public enum PrecipitationLevel: Codable {
    case light
    case middle
    case heavy
}
