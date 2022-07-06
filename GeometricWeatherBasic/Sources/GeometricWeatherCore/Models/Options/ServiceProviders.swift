//
//  ServiceProviders.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct WeatherSource: ReadableOption {
    
    public typealias ImplType = WeatherSource
    
    public static let accu = WeatherSource(
        key: "weather_source_accu",
        voiceKey: "weather_source_voice_accu",
        url: "accuweather.com",
        color: 0xef5823
    )
    public static let caiYun = WeatherSource(
        key: "weather_source_caiyun",
        voiceKey: "weather_source_voice_caiyun",
        url: "caiyunapp.com",
        color: 0x5ebb8e
    )
    
    public static let all = [accu, caiYun]
    
    public static subscript(index: Int) -> WeatherSource {
        get {
            return WeatherSource.all[index]
        }
    }
    
    public static subscript(key: String) -> WeatherSource {
        get {
            for item in WeatherSource.all {
                if item.key == key || item.key.contains(key) {
                    return item
                }
            }
            return WeatherSource.all[0]
        }
    }
    
    public let key: String
    public let voiceKey: String
    public let url: String
    public let color: Int
    
    private init(
        key: String,
        voiceKey: String,
        url: String,
        color: Int
    ) {
        self.key = key
        self.voiceKey = voiceKey
        self.url = url
        self.color = color
    }
}
