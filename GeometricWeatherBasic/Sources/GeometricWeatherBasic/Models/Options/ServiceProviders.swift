//
//  ServiceProviders.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct WeatherSource: ReadableOption {
    
    public typealias ImplType = WeatherSource
    
    public static let all = [
        WeatherSource(
            key: "weather_source_accu",
            voiceKey: "weather_source_voice_accu",
            url: "accuweather.com",
            color: 0xef5823
        )
    ]
    
    public static subscript(index: Int) -> WeatherSource {
        get {
            return WeatherSource.all[0]
        }
    }
    
    public static subscript(key: String) -> WeatherSource {
        get {
            return WeatherSource.all[0]
        }
    }
    
    public let key: String
    public let voiceKey: String
    public let url: String
    public let color: Int
    
    public init(key: String, voiceKey: String, url: String, color: Int) {
        self.key = key
        self.voiceKey = voiceKey
        self.url = url
        self.color = color
    }
}
