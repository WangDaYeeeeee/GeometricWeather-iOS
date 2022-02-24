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
    
    public let wind: Wind?
    public let airQuality: AirQuality
    public let pollen: Pollen
    public let uv: UV
    public let hoursOfSun: Double?
    
    public init(
        time: TimeInterval,
        day: HalfDay,
        night: HalfDay,
        sun: Astro,
        moon: Astro,
        moonPhase: MoonPhase,
        wind: Wind?,
        airQuality: AirQuality,
        pollen: Pollen,
        uv: UV,
        hoursOfSun: Double?
    ) {
        self.time = time
        self.day = day
        self.night = night
        self.sun = sun
        self.moon = moon
        self.moonPhase = moonPhase
        self.wind = wind
        self.airQuality = airQuality
        self.pollen = pollen
        self.uv = uv
        self.hoursOfSun = hoursOfSun
    }
    
    public func getDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: Date(timeIntervalSince1970: time))
    }

    // 1 - 7.
    public func getWeek(timezone: TimeZone) -> Int {
        let weekday = Calendar.current.component(
            .weekday,
            from: Date(timeIntervalSince1970: time)
        )
        switch weekday {
        case 1:
            return 7
        default:
            return weekday - 1
        }
    }

    public func isToday(timezone: TimeZone) -> Bool {
        let dailyDate = Date(timeIntervalSince1970: self.time)
        let year = Calendar.current.component(.year, from: dailyDate)
        let month = Calendar.current.component(.month, from: dailyDate)
        let day = Calendar.current.component(.day, from: dailyDate)
        
        let localDate = Date(
            timeIntervalSince1970: Date().timeIntervalSince1970 + Double(
                timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
            )
        )
        let localYear = Calendar.current.component(.year, from: localDate)
        let localMonth = Calendar.current.component(.month, from: localDate)
        let localDay = Calendar.current.component(.day, from: localDate)

        return year == localYear
            && month == localMonth
            && day == localDay
    }
}
