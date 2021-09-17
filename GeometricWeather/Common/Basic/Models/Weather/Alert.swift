//
//  Alert.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

struct Alert: Codable {
    
    let alertId: Int64
    let time: TimeInterval

    let description: String
    let content: String

    let type: String
    let priority: Int
    let color: Int;
    
    init(
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
    
    static func deduplicate(
        alertArray: Array<Alert>
    ) -> Array<Alert> {
        var typeSet = Set<String>()
        
        var result = [Alert]()
        for alert in alertArray {
            if typeSet.insert(alert.type).inserted {
                result.append(alert)
            }
        }
        
        return result
    }
    
    static func descByTime(
        alertArray: Array<Alert>
    ) -> Array<Alert> {
        return alertArray.sorted { alert1, alert2 in
            return alert1.time > alert2.time
        }
    }
}
