//
//  Utils.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/14.
//

import Foundation

public func formateTime(
    timeIntervalSine1970: TimeInterval,
    twelveHour: Bool
) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = twelveHour ? "h:mm aa" : "HH:mm"
    
    return formatter.string(from: Date(timeIntervalSince1970: timeIntervalSine1970))
}
