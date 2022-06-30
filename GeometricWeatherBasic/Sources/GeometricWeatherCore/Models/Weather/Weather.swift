//
//  Weather.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/12.
//

import Foundation

public struct Weather: Codable, Equatable {
    
    public let base: Base
    public let current: Current
    
    public let yesterday: History?
    
    public let dailyForecasts: Array<Daily>
    public let hourlyForecasts: Array<Hourly>
    public let minutelyForecast: Minutely?
    public let alerts: Array<WeatherAlert>
    
    public init(
        base: Base,
        current: Current,
        yesterday: History?,
        dailyForecasts: Array<Daily>,
        hourlyForecasts: Array<Hourly>,
        minutelyForecast: Minutely?,
        alerts: Array<WeatherAlert>
    ) {
        self.base = base
        self.current = current
        self.yesterday = yesterday
        self.dailyForecasts = dailyForecasts
        self.hourlyForecasts = hourlyForecasts
        self.minutelyForecast = minutelyForecast
        self.alerts = alerts
    }
    
    public static func == (left: Weather, right: Weather) -> Bool {
        return left.base.timeStamp == right.base.timeStamp
    }
    
    public func isValid(pollingIntervalHours: Double) -> Bool {
        let updateTime = base.timeStamp
        let currentTime = Date().timeIntervalSince1970
    
        return currentTime >= updateTime
                && currentTime - updateTime < pollingIntervalHours * 60 * 60;
    }
}
