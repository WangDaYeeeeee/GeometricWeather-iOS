//
//  ServiceProviders.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

struct WeatherSource: ReadableOption {
    
    typealias ImplType = WeatherSource
    
    static let all = [
        WeatherSource(
            key: "weather_source_accu",
            voiceKey: "weather_source_voice_accu",
            url: "accuweather.com",
            color: 0xef5823
        )
    ]
    
    static subscript(index: Int) -> WeatherSource {
        get {
            return WeatherSource.all[0]
        }
    }
    
    static subscript(key: String) -> WeatherSource {
        get {
            return WeatherSource.all[0]
        }
    }
    
    let key: String
    let voiceKey: String
    let url: String
    let color: Int
    
    init(key: String, voiceKey: String, url: String, color: Int) {
        self.key = key
        self.voiceKey = voiceKey
        self.url = url
        self.color = color
    }
}
