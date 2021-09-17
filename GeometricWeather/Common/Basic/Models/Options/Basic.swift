//
//  Basic.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

struct UpdateInterval: Option {
    
    typealias ImplType = UpdateInterval
    
    static var all = [
        UpdateInterval(
            key: "update_interval_1",
            hours: 1.0
        ),
        UpdateInterval(
            key: "update_interval_2",
            hours: 2.0
        ),
        UpdateInterval(
            key: "update_interval_3",
            hours: 3.0
        ),
        UpdateInterval(
            key: "update_interval_4",
            hours: 4.0
        ),
    ]
    
    static subscript(index: Int) -> UpdateInterval {
        get {
            return UpdateInterval.all[index]
        }
    }
    
    static subscript(key: String) -> UpdateInterval {
        get {
            for item in UpdateInterval.all {
                if item.key == key {
                    return item
                }
            }
            return UpdateInterval.all[0]
        }
    }
    
    let key: String
    let hours: Double
    
    init(key: String, hours: Double) {
        self.key = key
        self.hours = hours
    }
}
