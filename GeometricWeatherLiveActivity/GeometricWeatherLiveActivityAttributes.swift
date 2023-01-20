//
//  PrecipitationLiveActivity.swift
//  GeometricWeatherLiveActivityExtension
//
//  Created by 王大爷 on 2023/1/18.
//

import ActivityKit
import WidgetKit
import SwiftUI
import GeometricWeatherCore

public struct PrecipitationActivityAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        let currentTimeSince1970: Double
    }

    let locationName: String
    let locationFormattedId: String
    let isDaylight: Bool
    let isCurrentPosition: Bool
    let timestamp: TimeInterval
    let timezone: TimeZone
    
    let weatherText: String
    let weatherCode: WeatherCode
    let temperature: Int
    let daytimeTemperature: Int
    let nighttimeTemperature: Int
    let forecastDescription: String
    
    let minutely: Minutely
}
