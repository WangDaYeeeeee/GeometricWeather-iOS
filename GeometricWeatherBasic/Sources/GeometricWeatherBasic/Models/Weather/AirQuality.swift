//
//  AirQuality.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct AirQuality: Codable {
    
    public let aqiLevel: Int?
    public let aqiIndex: Int?
    public let pm25: Double?
    public let pm10: Double?
    public let so2: Double?
    public let no2: Double?
    public let o3: Double?
    public let co: Double?
    
    public static let aqiIndexLevel1 = 50;
    public static let aqiIndexLevel2 = 100;
    public static let aqiIndexLevel3 = 150;
    public static let aqiIndexLevel4 = 200;
    public static let aqiIndexLevel5 = 300;
    
    public init(
        aqiLevel: Int?,
        aqiIndex: Int?,
        pm25: Double?,
        pm10: Double?,
        so2: Double?,
        no2: Double?,
        o3: Double?,
        co: Double?
    ) {
        self.aqiLevel = aqiLevel
        self.aqiIndex = aqiIndex
        self.pm25 = pm25
        self.pm10 = pm10
        self.so2 = so2
        self.no2 = no2
        self.o3 = o3
        self.co = co
    }
    
    public func getAqiLevel() -> Int {
        if (aqiIndex == nil) {
            return 1
        } else if aqiIndex! <= Self.aqiIndexLevel1 {
            return 1
        } else if aqiIndex! <= Self.aqiIndexLevel2 {
            return 2
        } else if aqiIndex! <= Self.aqiIndexLevel3 {
            return 3
        } else if aqiIndex! <= Self.aqiIndexLevel4 {
            return 4
        } else if aqiIndex! <= Self.aqiIndexLevel5 {
            return 5
        } else {
            return 6
        }
    }
    
    public func getPm25Level() -> Int {
        if (pm25 == nil) {
            return 1
        } else if pm25! <= 35 {
            return 1
        } else if pm25! <= 75 {
            return 2
        } else if pm25! <= 115 {
            return 3
        } else if pm25! <= 150 {
            return 4
        } else if pm25! <= 250 {
            return 5
        } else {
            return 6
        }
    }
    
    public func getPm10Level() -> Int {
        if (pm10 == nil) {
            return 1
        } else if pm10! <= 50 {
            return 1
        } else if pm10! <= 150 {
            return 2
        } else if pm10! <= 250 {
            return 3
        } else if pm10! <= 350 {
            return 4
        } else if pm10! <= 420 {
            return 5
        } else {
            return 6
        }
    }
    
    public func getSo2Level() -> Int {
        if (so2 == nil) {
            return 1
        } else if so2! <= 50 {
            return 1
        } else if so2! <= 150 {
            return 2
        } else if so2! <= 475 {
            return 3
        } else if so2! <= 800 {
            return 4
        } else if so2! <= 1600 {
            return 5
        } else {
            return 6
        }
    }
    
    public func getNo2Level() -> Int {
        if (no2 == nil) {
            return 1
        } else if no2! <= 40 {
            return 1
        } else if no2! <= 80 {
            return 2
        } else if no2! <= 180 {
            return 3
        } else if no2! <= 280 {
            return 4
        } else if no2! <= 565 {
            return 5
        } else {
            return 6
        }
    }
    
    public func getO3Level() -> Int {
        if (o3 == nil) {
            return 1
        } else if o3! <= 160 {
            return 1
        } else if o3! <= 200 {
            return 2
        } else if o3! <= 300 {
            return 3
        } else if o3! <= 400 {
            return 4
        } else if o3! <= 800 {
            return 5
        } else {
            return 6
        }
    }
    
    public func getCOLevel() -> Int {
        if (co == nil) {
            return 1
        } else if co! <= 5 {
            return 1
        } else if co! <= 10 {
            return 2
        } else if co! <= 35 {
            return 3
        } else if co! <= 60 {
            return 4
        } else if co! <= 90 {
            return 5
        } else {
            return 6
        }
    }

    public func isValid() -> Bool {
        return aqiIndex != nil
                || aqiLevel != nil
                || pm25 != nil
                || pm10 != nil
                || so2 != nil
                || no2 != nil
                || o3 != nil
                || co != nil
    }
}
