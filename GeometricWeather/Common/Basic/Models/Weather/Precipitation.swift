//
//  Precipitation.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

struct Precipitation: Codable {
    
    let total: Double?
    let thunderstorm: Double?
    let rain: Double?
    let snow: Double?
    let ice: Double?
    
    init(
        total: Double?,
        thunderstorm: Double? = nil,
        rain: Double? = nil,
        snow: Double? = nil,
        ice: Double? = nil
    ) {
        self.total = total
        self.thunderstorm = thunderstorm
        self.rain = rain
        self.snow = snow
        self.ice = ice
    }
    
    static let precipitationLight = 10.0
    static let precipitationMiddle = 25.0
    static let precipitationHeavy = 50.0
    static let precipitationRainstrom = 100.0
    
    func isValid() -> Bool {
        if let p = total {
            return p > 0
        } else {
            return false
        }
    }
    
    func getPrecipitationLevel() -> Int {
        if (total == nil) {
            return 1
        } else if (total! <= Self.precipitationLight) {
            return 1
        } else if (total! <= Self.precipitationMiddle) {
            return 2
        } else if (total! <= Self.precipitationHeavy) {
            return 3
        } else if (total! <= Self.precipitationRainstrom) {
            return 4
        } else {
            return 5
        }
    }
}
