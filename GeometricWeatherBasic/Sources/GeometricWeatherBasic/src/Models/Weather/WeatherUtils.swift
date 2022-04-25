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

public func getPrecipitationProbLevel(_ prob: Double) -> Int {
    if prob < 10.0 {
        return 1
    }
    if prob < 25.0 {
        return 2
    }
    if prob < 50.0 {
        return 3
    }
    if prob < 75.0 {
        return 4
    }
    if prob < 90.0 {
        return 5
    }
    return 6
}

public func getDailyPrecipitationLevel(_ precipitation: Double) -> Int {
    if precipitation < dailyPrecipitationLight {
        return 1
    }
    if precipitation < dailyPrecipitationMiddle {
        return 2
    }
    if precipitation < dailyPrecipitationHeavy {
        return 3
    }
    if precipitation < dailyPrecipitationRainstrom {
        return 4
    }
    if precipitation < dailyPrecipitationRainstrom * 2 {
        return 5
    }
    return 6
}

public func getHourlyPrecipitationLevel(_ precipitation: Double) -> Int {
    if precipitation < hourlyPrecipitationLight {
        return 1
    }
    if precipitation < hourlyPrecipitationMiddle {
        return 2
    }
    if precipitation < hourlyPrecipitationHeavy {
        return 3
    }
    if precipitation < hourlyPrecipitationRainstrom {
        return 4
    }
    if precipitation < hourlyPrecipitationRainstrom * 2 {
        return 5
    }
    return 6
}

public func getPrecipitationIntensityLevel(_ intensity: Double) -> Int {
    if intensity < radarPrecipitationIntensityLight {
        return 1
    }
    if intensity < radarPrecipitationIntensityMiddle {
        return 2
    }
    if intensity < radarPrecipitationIntensityHeavy {
        return 3
    }
    if intensity < radarPrecipitationIntensityRainstrom {
        return 4
    }
    if intensity < radarPrecipitationIntensityRainstrom * 2 {
        return 5
    }
    return 6
}
