//
//  Precipitation.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct Precipitation: Codable {
    
    public let total: Double?
    public let thunderstorm: Double?
    public let rain: Double?
    public let snow: Double?
    public let ice: Double?
    
    public init(
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
    
    public static let precipitationLight = 10.0
    public static let precipitationMiddle = 25.0
    public static let precipitationHeavy = 50.0
    public static let precipitationRainstrom = 100.0
    
    public func isValid() -> Bool {
        if let p = total {
            return p > 0
        } else {
            return false
        }
    }
    
    public func getPrecipitationLevel() -> Int {
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
