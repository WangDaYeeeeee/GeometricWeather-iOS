//
//  Utils.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/14.
//

import Foundation

public func formatTime(
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

public func getPrecipitationIntensityLevel(_ precipitation: Double) -> Int {
    if precipitation < precipitationIntensityLight {
        return 1
    }
    if precipitation < precipitationIntensityMiddle {
        return 2
    }
    if precipitation < precipitationIntensityHeavy {
        return 3
    }
    if precipitation < precipitationIntensityRainstrom {
        return 4
    }
    if precipitation < precipitationIntensityRainstrom * 2 {
        return 5
    }
    return 6
}

public func getVisibilityLevel(_ visibility: Double) -> Int {
    if visibility >= 10.0 {
        return 1
    }
    if visibility >= 8.0 {
        return 2
    }
    if visibility >= 6.0 {
        return 3
    }
    if visibility >= 4.0 {
        return 4
    }
    if visibility >= 2.0 {
        return 5
    }
    return 6
}

public func getCloudrateLevel(_ cloudrate: Double) -> Int {
    if cloudrate <= 2.0 / 8.0 {
        return 1
    }
    if cloudrate <= 4.0 / 8.0 {
        return 2
    }
    if cloudrate <= 5.0 / 8.0 {
        return 3
    }
    if cloudrate <= 6.0 / 8.0 {
        return 4
    }
    if cloudrate <= 7.0 / 8.0 {
        return 5
    }
    return 6
}
