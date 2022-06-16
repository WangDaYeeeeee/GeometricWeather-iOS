//
//  Basic.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct UpdateInterval: Option {
    
    public typealias ImplType = UpdateInterval
    
    public static let anHour = UpdateInterval(
        key: "update_interval_1",
        hours: 1.0
    )
    public static let twoHour = UpdateInterval(
        key: "update_interval_2",
        hours: 2.0
    )
    public static let threeHour = UpdateInterval(
        key: "update_interval_3",
        hours: 3.0
    )
    public static let fourHour = UpdateInterval(
        key: "update_interval_4",
        hours: 4.0
    )
    
    public static var all = [anHour, twoHour, threeHour, fourHour]
    
    public static subscript(index: Int) -> UpdateInterval {
        get {
            return UpdateInterval.all[index]
        }
    }
    
    public static subscript(key: String) -> UpdateInterval {
        get {
            for item in UpdateInterval.all {
                if item.key == key {
                    return item
                }
            }
            return UpdateInterval.all[0]
        }
    }
    
    public let key: String
    public let hours: Double
    
    private init(key: String, hours: Double) {
        self.key = key
        self.hours = hours
    }
}
