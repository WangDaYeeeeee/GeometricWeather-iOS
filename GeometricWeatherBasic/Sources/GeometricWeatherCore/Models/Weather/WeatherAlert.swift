//
//  Alert.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct WeatherAlert: Codable {
    
    public let alertId: Int64
    public let time: TimeInterval

    public let description: String
    public let content: String

    public let type: String
    public let priority: Int
    public let color: Int;
    
    public init(
        alertId: Int64,
        time: TimeInterval,
        description: String,
        content: String,
        type: String,
        priority: Int,
        color: Int
    ) {
        self.alertId = alertId
        self.time = time
        self.description = description
        self.content = content
        self.type = type
        self.priority = priority
        self.color = color
    }
    
    public static func deduplicate(
        alertArray: Array<WeatherAlert>
    ) -> Array<WeatherAlert> {
        var typeSet = Set<String>()
        
        var result = [WeatherAlert]()
        for alert in alertArray {
            if typeSet.insert(alert.type).inserted {
                result.append(alert)
            }
        }
        
        return result
    }
    
    public static func descByTime(
        alertArray: Array<WeatherAlert>
    ) -> Array<WeatherAlert> {
        return alertArray.sorted { alert1, alert2 in
            return alert1.time > alert2.time
        }
    }
}
