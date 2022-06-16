// CaiYunWeatherResult.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let CaiYunWeatherResult = try? newJSONDecoder().decode(CaiYunWeatherResult.self, from: jsonData)

import Foundation

// MARK: - CaiYunWeatherResult
struct CaiYunWeatherResult: Codable {
    let status: String
    let apiVersion: String
    let apiStatus: String
    let lang: String
    let unit: String
    let tzshift: Int
    let timezone: String
    let serverTime: Int
    let location: [Double]
    let result: CaiYunResult

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case apiVersion = "api_version"
        case apiStatus = "api_status"
        case lang = "lang"
        case unit = "unit"
        case tzshift = "tzshift"
        case timezone = "timezone"
        case serverTime = "server_time"
        case location = "location"
        case result = "result"
    }
}

// CaiYunResult.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunResult = try? newJSONDecoder().decode(CaiYunResult.self, from: jsonData)

import Foundation

// MARK: - CaiYunResult
struct CaiYunResult: Codable {
    let alert: CaiYunAlertElement?
    let realtime: CaiYunRealtime
    let minutely: CaiYunMinutely
    let hourly: CaiYunHourly
    let daily: CaiYunDaily
    let primary: Int
    let forecastKeypoint: String

    enum CodingKeys: String, CodingKey {
        case alert = "alert"
        case realtime = "realtime"
        case minutely = "minutely"
        case hourly = "hourly"
        case daily = "daily"
        case primary = "primary"
        case forecastKeypoint = "forecast_keypoint"
    }
}

// CaiYunAlertElement.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunAlertElement = try? newJSONDecoder().decode(CaiYunAlertElement.self, from: jsonData)

import Foundation

// MARK: - CaiYunAlertElement
struct CaiYunAlertElement: Codable {
    let status: String
    let content: [CaiYunAlertContentElement]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case content = "content"
    }
}

// CaiYunAlertContentElement.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let CaiYunAlertContentElement = try? newJSONDecoder().decode(CaiYunAlertContentElement.self, from: jsonData)

import Foundation

// MARK: - CaiYunAlertContentElement
struct CaiYunAlertContentElement: Codable {
    let province: String
    let status: String
    let code: String
    let alertDescription: String
    let regionId: String
    let county: String
    let pubtimestamp: Int
    let latlon: [Double]
    let city: String
    let alertId: String
    let title: String
    let adcode: String
    let source: String
    let location: String
    let requestStatus: String

    enum CodingKeys: String, CodingKey {
        case province = "province"
        case status = "status"
        case code = "code"
        case alertDescription = "description"
        case regionId = "regionId"
        case county = "county"
        case pubtimestamp = "pubtimestamp"
        case latlon = "latlon"
        case city = "city"
        case alertId = "alertId"
        case title = "title"
        case adcode = "adcode"
        case source = "source"
        case location = "location"
        case requestStatus = "request_status"
    }
}

// CaiYunDaily.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunDaily = try? newJSONDecoder().decode(CaiYunDaily.self, from: jsonData)

import Foundation

// MARK: - CaiYunDaily
struct CaiYunDaily: Codable {
    let status: String
    let astro: [CaiYunAstro]
    let precipitation: [CaiYunDailyCloudrate]
    let temperature: [CaiYunDailyCloudrate]
    let wind: [CaiYunDailyWind]
    let wind08H20H: [CaiYunDailyWind]
    let wind20H32H: [CaiYunDailyWind]
    let humidity: [CaiYunDailyCloudrate]
    let cloudrate: [CaiYunDailyCloudrate]
    let pressure: [CaiYunDailyCloudrate]
    let visibility: [CaiYunDailyCloudrate]
    let dswrf: [CaiYunDailyCloudrate]
    let airQuality: CaiYunDailyAirQuality
    let skycon: [CaiYunSkycon08H20HElement]
    let skycon08H20H: [CaiYunSkycon08H20HElement]
    let skycon20H32H: [CaiYunSkycon08H20HElement]
    let lifeIndex: CaiYunDailyLifeIndex

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case astro = "astro"
        case precipitation = "precipitation"
        case temperature = "temperature"
        case wind = "wind"
        case wind08H20H = "wind_08h_20h"
        case wind20H32H = "wind_20h_32h"
        case humidity = "humidity"
        case cloudrate = "cloudrate"
        case pressure = "pressure"
        case visibility = "visibility"
        case dswrf = "dswrf"
        case airQuality = "air_quality"
        case skycon = "skycon"
        case skycon08H20H = "skycon_08h_20h"
        case skycon20H32H = "skycon_20h_32h"
        case lifeIndex = "life_index"
    }
}

// CaiYunDailyAirQuality.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunDailyAirQuality = try? newJSONDecoder().decode(CaiYunDailyAirQuality.self, from: jsonData)

import Foundation

// MARK: - CaiYunDailyAirQuality
struct CaiYunDailyAirQuality: Codable {
    let aqi: [CaiYunPurpleAqi]
    let pm25: [CaiYunDailyCloudrate]

    enum CodingKeys: String, CodingKey {
        case aqi = "aqi"
        case pm25 = "pm25"
    }
}

// CaiYunPurpleAqi.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunPurpleAqi = try? newJSONDecoder().decode(CaiYunPurpleAqi.self, from: jsonData)

import Foundation

// MARK: - CaiYunPurpleAqi
struct CaiYunPurpleAqi: Codable {
    let date: String
    let max: CaiYunAvgClass
    let avg: CaiYunAvgClass
    let min: CaiYunAvgClass

    enum CodingKeys: String, CodingKey {
        case date = "date"
        case max = "max"
        case avg = "avg"
        case min = "min"
    }
}

// CaiYunAvgClass.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunAvgClass = try? newJSONDecoder().decode(CaiYunAvgClass.self, from: jsonData)

import Foundation

// MARK: - CaiYunAvgClass
struct CaiYunAvgClass: Codable {
    let chn: Double
    let usa: Double

    enum CodingKeys: String, CodingKey {
        case chn = "chn"
        case usa = "usa"
    }
}

// CaiYunDailyCloudrate.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunDailyCloudrate = try? newJSONDecoder().decode(CaiYunDailyCloudrate.self, from: jsonData)

import Foundation

// MARK: - CaiYunDailyCloudrate
struct CaiYunDailyCloudrate: Codable {
    let date: String
    let max: Double
    let avg: Double
    let min: Double

    enum CodingKeys: String, CodingKey {
        case date = "date"
        case max = "max"
        case avg = "avg"
        case min = "min"
    }
}

// CaiYunAstro.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunAstro = try? newJSONDecoder().decode(CaiYunAstro.self, from: jsonData)

import Foundation

// MARK: - CaiYunAstro
struct CaiYunAstro: Codable {
    let date: String
    let sunrise: CaiYunSun
    let sunset: CaiYunSun

    enum CodingKeys: String, CodingKey {
        case date = "date"
        case sunrise = "sunrise"
        case sunset = "sunset"
    }
}

// CaiYunSun.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunSun = try? newJSONDecoder().decode(CaiYunSun.self, from: jsonData)

import Foundation

// MARK: - CaiYunSun
struct CaiYunSun: Codable {
    let time: String

    enum CodingKeys: String, CodingKey {
        case time = "time"
    }
}

// CaiYunDailyLifeIndex.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunDailyLifeIndex = try? newJSONDecoder().decode(CaiYunDailyLifeIndex.self, from: jsonData)

import Foundation

// MARK: - CaiYunDailyLifeIndex
struct CaiYunDailyLifeIndex: Codable {
    let ultraviolet: [CaiYunCarWashing]
    let carWashing: [CaiYunCarWashing]
    let dressing: [CaiYunCarWashing]
    let comfort: [CaiYunCarWashing]
    let coldRisk: [CaiYunCarWashing]

    enum CodingKeys: String, CodingKey {
        case ultraviolet = "ultraviolet"
        case carWashing = "carWashing"
        case dressing = "dressing"
        case comfort = "comfort"
        case coldRisk = "coldRisk"
    }
}

// CaiYunCarWashing.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunCarWashing = try? newJSONDecoder().decode(CaiYunCarWashing.self, from: jsonData)

import Foundation

// MARK: - CaiYunCarWashing
struct CaiYunCarWashing: Codable {
    let date: String
    let index: String
    let desc: String

    enum CodingKeys: String, CodingKey {
        case date = "date"
        case index = "index"
        case desc = "desc"
    }
}

// CaiYunSkycon08H20HElement.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunSkycon08H20HElement = try? newJSONDecoder().decode(CaiYunSkycon08H20HElement.self, from: jsonData)

import Foundation

// MARK: - CaiYunSkycon08H20HElement
struct CaiYunSkycon08H20HElement: Codable {
    let date: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case date = "date"
        case value = "value"
    }
}

// CaiYunDailyWind.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunDailyWind = try? newJSONDecoder().decode(CaiYunDailyWind.self, from: jsonData)

import Foundation

// MARK: - CaiYunDailyWind
struct CaiYunDailyWind: Codable {
    let date: String
    let max: CaiYunMaxClass
    let min: CaiYunMaxClass
    let avg: CaiYunMaxClass

    enum CodingKeys: String, CodingKey {
        case date = "date"
        case max = "max"
        case min = "min"
        case avg = "avg"
    }
}

// CaiYunMaxClass.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunMaxClass = try? newJSONDecoder().decode(CaiYunMaxClass.self, from: jsonData)

import Foundation

// MARK: - CaiYunMaxClass
struct CaiYunMaxClass: Codable {
    let speed: Double
    let direction: Double

    enum CodingKeys: String, CodingKey {
        case speed = "speed"
        case direction = "direction"
    }
}

// CaiYunHourly.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunHourly = try? newJSONDecoder().decode(CaiYunHourly.self, from: jsonData)

import Foundation

// MARK: - CaiYunHourly
struct CaiYunHourly: Codable {
    let status: String
    let hourlyDescription: String
    let precipitation: [CaiYunHourlyCloudrate]
    let temperature: [CaiYunHourlyCloudrate]
    let apparentTemperature: [CaiYunHourlyCloudrate]
    let wind: [CaiYunHourlyWind]
    let humidity: [CaiYunHourlyCloudrate]
    let cloudrate: [CaiYunHourlyCloudrate]
    let skycon: [CaiYunHourlySkycon]
    let pressure: [CaiYunHourlyCloudrate]
    let visibility: [CaiYunHourlyCloudrate]
    let dswrf: [CaiYunHourlyCloudrate]
    let airQuality: CaiYunHourlyAirQuality

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case hourlyDescription = "description"
        case precipitation = "precipitation"
        case temperature = "temperature"
        case apparentTemperature = "apparent_temperature"
        case wind = "wind"
        case humidity = "humidity"
        case cloudrate = "cloudrate"
        case skycon = "skycon"
        case pressure = "pressure"
        case visibility = "visibility"
        case dswrf = "dswrf"
        case airQuality = "air_quality"
    }
}

// CaiYunHourlyAirQuality.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunHourlyAirQuality = try? newJSONDecoder().decode(CaiYunHourlyAirQuality.self, from: jsonData)

import Foundation

// MARK: - CaiYunHourlyAirQuality
struct CaiYunHourlyAirQuality: Codable {
    let aqi: [CaiYunFluffyAqi]
    let pm25: [CaiYunHourlyCloudrate]

    enum CodingKeys: String, CodingKey {
        case aqi = "aqi"
        case pm25 = "pm25"
    }
}

// CaiYunFluffyAqi.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunFluffyAqi = try? newJSONDecoder().decode(CaiYunFluffyAqi.self, from: jsonData)

import Foundation

// MARK: - CaiYunFluffyAqi
struct CaiYunFluffyAqi: Codable {
    let datetime: String
    let value: CaiYunAvgClass

    enum CodingKeys: String, CodingKey {
        case datetime = "datetime"
        case value = "value"
    }
}

// CaiYunHourlyCloudrate.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunHourlyCloudrate = try? newJSONDecoder().decode(CaiYunHourlyCloudrate.self, from: jsonData)

import Foundation

// MARK: - CaiYunHourlyCloudrate
struct CaiYunHourlyCloudrate: Codable {
    let datetime: String
    let value: Double

    enum CodingKeys: String, CodingKey {
        case datetime = "datetime"
        case value = "value"
    }
}

// CaiYunHourlySkycon.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunHourlySkycon = try? newJSONDecoder().decode(CaiYunHourlySkycon.self, from: jsonData)

import Foundation

// MARK: - CaiYunHourlySkycon
struct CaiYunHourlySkycon: Codable {
    let datetime: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case datetime = "datetime"
        case value = "value"
    }
}

// CaiYunHourlyWind.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunHourlyWind = try? newJSONDecoder().decode(CaiYunHourlyWind.self, from: jsonData)

import Foundation

// MARK: - CaiYunHourlyWind
struct CaiYunHourlyWind: Codable {
    let datetime: String
    let speed: Double
    let direction: Double

    enum CodingKeys: String, CodingKey {
        case datetime = "datetime"
        case speed = "speed"
        case direction = "direction"
    }
}

// CaiYunMinutely.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunMinutely = try? newJSONDecoder().decode(CaiYunMinutely.self, from: jsonData)

import Foundation

// MARK: - CaiYunMinutely
struct CaiYunMinutely: Codable {
    let status: String
    let datasource: String
    let precipitation2H: [Double]
    let precipitation: [Double]
    let probability: [Double]
    let minutelyDescription: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case datasource = "datasource"
        case precipitation2H = "precipitation_2h"
        case precipitation = "precipitation"
        case probability = "probability"
        case minutelyDescription = "description"
    }
}

// CaiYunRealtime.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunRealtime = try? newJSONDecoder().decode(CaiYunRealtime.self, from: jsonData)

import Foundation

// MARK: - CaiYunRealtime
struct CaiYunRealtime: Codable {
    let status: String
    let temperature: Double
    let humidity: Double
    let cloudrate: Double
    let skycon: String
    let visibility: Double
    let dswrf: Double
    let wind: CaiYunMaxClass
    let pressure: Double
    let apparentTemperature: Double
    let precipitation: CaiYunPrecipitation
    let airQuality: CaiYunRealtimeAirQuality
    let lifeIndex: CaiYunRealtimeLifeIndex

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case temperature = "temperature"
        case humidity = "humidity"
        case cloudrate = "cloudrate"
        case skycon = "skycon"
        case visibility = "visibility"
        case dswrf = "dswrf"
        case wind = "wind"
        case pressure = "pressure"
        case apparentTemperature = "apparent_temperature"
        case precipitation = "precipitation"
        case airQuality = "air_quality"
        case lifeIndex = "life_index"
    }
}

// CaiYunRealtimeAirQuality.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunRealtimeAirQuality = try? newJSONDecoder().decode(CaiYunRealtimeAirQuality.self, from: jsonData)

import Foundation

// MARK: - CaiYunRealtimeAirQuality
struct CaiYunRealtimeAirQuality: Codable {
    let pm25: Double
    let pm10: Double
    let o3: Double
    let so2: Double
    let no2: Double
    let co: Double
    let aqi: CaiYunAvgClass
    let airQualityDescription: CaiYunDescription

    enum CodingKeys: String, CodingKey {
        case pm25 = "pm25"
        case pm10 = "pm10"
        case o3 = "o3"
        case so2 = "so2"
        case no2 = "no2"
        case co = "co"
        case aqi = "aqi"
        case airQualityDescription = "description"
    }
}

// CaiYunDescription.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunDescription = try? newJSONDecoder().decode(CaiYunDescription.self, from: jsonData)

import Foundation

// MARK: - CaiYunDescription
struct CaiYunDescription: Codable {
    let usa: String
    let chn: String

    enum CodingKeys: String, CodingKey {
        case usa = "usa"
        case chn = "chn"
    }
}

// CaiYunRealtimeLifeIndex.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunRealtimeLifeIndex = try? newJSONDecoder().decode(CaiYunRealtimeLifeIndex.self, from: jsonData)

import Foundation

// MARK: - CaiYunRealtimeLifeIndex
struct CaiYunRealtimeLifeIndex: Codable {
    let ultraviolet: CaiYunComfort
    let comfort: CaiYunComfort

    enum CodingKeys: String, CodingKey {
        case ultraviolet = "ultraviolet"
        case comfort = "comfort"
    }
}

// CaiYunComfort.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunComfort = try? newJSONDecoder().decode(CaiYunComfort.self, from: jsonData)

import Foundation

// MARK: - CaiYunComfort
struct CaiYunComfort: Codable {
    let index: Double
    let desc: String

    enum CodingKeys: String, CodingKey {
        case index = "index"
        case desc = "desc"
    }
}

// CaiYunPrecipitation.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunPrecipitation = try? newJSONDecoder().decode(CaiYunPrecipitation.self, from: jsonData)

import Foundation

// MARK: - CaiYunPrecipitation
struct CaiYunPrecipitation: Codable {
    let local: CaiYunLocal

    enum CodingKeys: String, CodingKey {
        case local = "local"
    }
}

// CaiYunLocal.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let caiYunLocal = try? newJSONDecoder().decode(CaiYunLocal.self, from: jsonData)

import Foundation

// MARK: - CaiYunLocal
struct CaiYunLocal: Codable {
    let status: String
    let datasource: String
    let intensity: Double

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case datasource = "datasource"
        case intensity = "intensity"
    }
}

// JSONSchemaSupport.swift

import Foundation
