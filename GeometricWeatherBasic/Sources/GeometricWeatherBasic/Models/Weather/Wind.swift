//
//  Wind.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct Wind: Codable {
    
    public let direction: String?
    public let degree: WindDegree
    public let speed: Double?
    public let level: Int
    
    public static let windSpeedLevel0 = 2.0
    public static let windSpeedLevel1 = 6.0
    public static let windSpeedLevel2 = 12.0
    public static let windSpeedLevel3 = 19.0
    public static let windSpeedLevel4 = 30.0
    public static let windSpeedLevel5 = 40.0
    public static let windSpeedLevel6 = 51.0
    public static let windSpeedLevel7 = 62.0
    public static let windSpeedLevel8 = 75.0
    public static let windSpeedLevel9 = 87.0
    public static let windSpeedLevel10 = 103.0
    public static let windSpeedLevel11 = 117.0
    
    public init(direction: String?, degree: WindDegree, speed: Double?, level: Int) {
        self.direction = direction
        self.degree = degree
        self.speed = speed
        self.level = level
    }
    
    public func getWindLevel() -> Int {
        if (speed == nil) {
            return 1
        } else if (speed! <= Self.windSpeedLevel3) {
            return 1
        } else if (speed! <= Self.windSpeedLevel5) {
            return 2
        } else if (speed! <= Self.windSpeedLevel7) {
            return 3
        } else if (speed! <= Self.windSpeedLevel9) {
            return 4
        } else if (speed! <= Self.windSpeedLevel11) {
            return 5
        } else {
            return 6
        }
    }

    public func isValidSpeed() -> Bool {
        if let sp = speed {
            return sp > 0
        } else {
            return false
        }
    }
}

public struct WindDegree: Codable {
    
    let degree: Double
    let noDirection: Bool
    
    public init(degree: Double, noDirection: Bool) {
        self.degree = degree
        self.noDirection = noDirection
    }

    public func getWindArrow() -> String {
        if (noDirection) {
            return "";
        } else if (22.5 < degree && degree <= 67.5) {
            return "↙";
        } else if (67.5 < degree && degree <= 112.5) {
            return "←";
        } else if (112.5 < degree && degree <= 157.5) {
            return "↖";
        } else if (157.5 < degree && degree <= 202.5) {
            return "↑";
        } else if (202.5 < degree && degree <= 247.5) {
            return "↗";
        } else if (247.5 < degree && degree <= 292.5) {
            return "→";
        } else if (292.5 < degree && degree <= 337.5) {
            return "↘";
        } else {
            return "↓";
        }
    }
}
