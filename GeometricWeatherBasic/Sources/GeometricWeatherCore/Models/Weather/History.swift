//
//  History.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/14.
//

import Foundation

public struct History: Codable {
    
    public let time: TimeInterval
    
    public let daytimeTemperature: Int?
    public let nighttimeTemperature: Int?
    
    public init(time: TimeInterval, daytimeTemperature: Int?, nighttimeTemperature: Int?) {
        self.time = time
        self.daytimeTemperature = daytimeTemperature
        self.nighttimeTemperature = nighttimeTemperature
    }
}
