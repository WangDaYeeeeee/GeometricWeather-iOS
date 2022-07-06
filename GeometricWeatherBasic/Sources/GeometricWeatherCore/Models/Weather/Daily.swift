//
//  Daily.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

public struct Daily: Codable {
    
    // local time.
    public let time: TimeInterval
    
    public let day: HalfDay
    public let night: HalfDay
    
    public let sun: Astro
    public let moon: Astro
    public let moonPhase: MoonPhase
    
    public let precipitationTotal: Double?
    public let precipitationIntensity: Double?
    public let precipitationProbability: Double?
    public let wind: Wind?
    public let airQuality: AirQuality
    public let pollen: Pollen
    public let uv: UV
    public let hoursOfSun: Double?
    public let pressure: Double?
    public let cloudrate: Double? // 0 - 1.
    public let visibility: Double?
    public let humidity: Double?
    
    // 1 - 7.
    public var week: Int {
        let weekday = Calendar.current.component(
            .weekday,
            from: Date(timeIntervalSince1970: self.time)
        )
        switch weekday {
        case 1:
            return 7
        default:
            return weekday - 1
        }
    }
    
    public init(
        time: TimeInterval,
        day: HalfDay,
        night: HalfDay,
        sun: Astro,
        moon: Astro,
        moonPhase: MoonPhase,
        precipitationTotal: Double?,
        precipitationIntensity: Double?,
        precipitationProbability: Double?,
        wind: Wind?,
        airQuality: AirQuality,
        pollen: Pollen,
        uv: UV,
        hoursOfSun: Double?,
        pressure: Double?,
        cloudrate: Double?, // 0 - 1.
        visibility: Double?,
        humidity: Double?
    ) {
        self.time = time
        self.day = day
        self.night = night
        self.sun = sun
        self.moon = moon
        self.moonPhase = moonPhase
        self.precipitationTotal = precipitationTotal
        self.precipitationIntensity = precipitationIntensity
        self.precipitationProbability = precipitationProbability
        self.wind = wind
        self.airQuality = airQuality
        self.pollen = pollen
        self.uv = uv
        self.hoursOfSun = hoursOfSun
        self.pressure = pressure
        self.cloudrate = cloudrate
        self.visibility = visibility
        self.humidity = humidity
    }
    
    public func getDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: Date(timeIntervalSince1970: time))
    }

    public func isToday(timezone: TimeZone) -> Bool {
        let dailyDate = Date(timeIntervalSince1970: self.time)
        let year = Calendar.current.component(.year, from: dailyDate)
        let month = Calendar.current.component(.month, from: dailyDate)
        let day = Calendar.current.component(.day, from: dailyDate)
        
        let localDate = Date.now(in: timezone)
        let localYear = Calendar.current.component(.year, from: localDate)
        let localMonth = Calendar.current.component(.month, from: localDate)
        let localDay = Calendar.current.component(.day, from: localDate)

        return year == localYear
            && month == localMonth
            && day == localDay
    }
}
