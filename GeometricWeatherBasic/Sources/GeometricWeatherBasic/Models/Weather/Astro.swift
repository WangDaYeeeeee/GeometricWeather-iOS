//
//  Astro.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct Astro: Codable {
    
    public let riseTime: TimeInterval?
    public let setTime: TimeInterval?
    
    public init(riseTime: TimeInterval?, setTime: TimeInterval?) {
        self.riseTime = riseTime
        self.setTime = setTime
    }
    
    public func isValid() -> Bool {
        return riseTime != nil && setTime != nil
    }
    
    public func formateRiseTime(twelveHour: Bool) -> String {
        if let time = riseTime {
            return formateTime(timeIntervalSine1970: time, twelveHour: twelveHour)
        } else {
            return ""
        }
    }
    
    public func formateSetTime(twelveHour: Bool) -> String {
        if let time = setTime {
            return formateTime(timeIntervalSine1970: time, twelveHour: twelveHour)
        } else {
            return ""
        }
    }
}
