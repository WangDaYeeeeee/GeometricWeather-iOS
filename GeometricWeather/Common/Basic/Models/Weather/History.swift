//
//  History.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/14.
//

import Foundation

struct History: Codable {
    
    let time: TimeInterval
    
    let daytimeTemperature: Int?
    let nighttimeTemperature: Int?
    
    init(time: TimeInterval, daytimeTemperature: Int?, nighttimeTemperature: Int?) {
        self.time = time
        self.daytimeTemperature = daytimeTemperature
        self.nighttimeTemperature = nighttimeTemperature
    }
}
