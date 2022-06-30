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

    // (-inf, 0]: not yet rise.
    // (0,    1): has risen, not yet set.
    // [1,  inf): has gone down.
    public static func getRiseProgress(
        for astro: Astro?,
        in timezone: TimeZone
    ) -> Double {
        let secondPerHour = 60 * 60.0
        let defaultRiseHour = 6.0
        let defaultDurationHour = 12.0
        
        let timezoneDate = Date.now(in: timezone)
        let currentTime = Double(
            Calendar.current.component(.hour, from: timezoneDate) * 60
            + Calendar.current.component(.minute, from: timezoneDate)
        ) * 60.0
        
        guard
            let riseTime = astro?.riseTime,
            let setTime = astro?.setTime
        else {
            let riseHourMinuteTime = defaultRiseHour * secondPerHour
            let setHourMinuteTime = riseHourMinuteTime + defaultDurationHour * secondPerHour
            
            if setHourMinuteTime == riseHourMinuteTime {
                return -1
            }
            return (currentTime - riseHourMinuteTime) / (setHourMinuteTime - riseHourMinuteTime)
        }
        
        let riseDate = Date(timeIntervalSince1970: riseTime)
        let riseHourMinuteTime = Double(
            Calendar.current.component(.hour, from: riseDate) * 60
            + Calendar.current.component(.minute, from: riseDate)
        ) * 60.0
        
        var safeSetTime = setTime
        while safeSetTime <= riseTime {
            safeSetTime += 24 * secondPerHour
        }
        let setHourMinuteTime = riseHourMinuteTime + (safeSetTime - riseTime)
        
        return (currentTime - riseHourMinuteTime) / (setHourMinuteTime - riseHourMinuteTime)
    }
}
