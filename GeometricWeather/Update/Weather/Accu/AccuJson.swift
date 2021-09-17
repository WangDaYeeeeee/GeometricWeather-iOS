// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accuLocationResult = try? newJSONDecoder().decode(AccuLocationResult.self, from: jsonData)

import Foundation

// MARK: - AccuLocationResult
struct AccuLocationResult: Codable {
    let version: Int
    let key: String
    let type: String
    let rank: Int
    let localizedName: String
    let englishName: String
    let primaryPostalCode: String
    let region: AccuCountry
    let country: AccuCountry
    let administrativeArea: AccuAdministrativeArea
    let timeZone: AccuTimeZone
    let geoPosition: AccuGeoPosition
    let isAlias: Bool
    let dataSets: [String]

    enum CodingKeys: String, CodingKey {
        case version = "Version"
        case key = "Key"
        case type = "Type"
        case rank = "Rank"
        case localizedName = "LocalizedName"
        case englishName = "EnglishName"
        case primaryPostalCode = "PrimaryPostalCode"
        case region = "Region"
        case country = "Country"
        case administrativeArea = "AdministrativeArea"
        case timeZone = "TimeZone"
        case geoPosition = "GeoPosition"
        case isAlias = "IsAlias"
        case dataSets = "DataSets"
    }
}

// MARK: - AccuAdministrativeArea
struct AccuAdministrativeArea: Codable {
    let id: String
    let localizedName: String
    let englishName: String
    let level: Int
    let localizedType: String
    let englishType: String
    let countryID: String

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case localizedName = "LocalizedName"
        case englishName = "EnglishName"
        case level = "Level"
        case localizedType = "LocalizedType"
        case englishType = "EnglishType"
        case countryID = "CountryID"
    }
}

// MARK: - AccuCountry
struct AccuCountry: Codable {
    let id: String
    let localizedName: String
    let englishName: String

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case localizedName = "LocalizedName"
        case englishName = "EnglishName"
    }
}

// MARK: - AccuGeoPosition
struct AccuGeoPosition: Codable {
    let latitude: Double
    let longitude: Double
    let elevation: AccuValueWrapper

    enum CodingKeys: String, CodingKey {
        case latitude = "Latitude"
        case longitude = "Longitude"
        case elevation = "Elevation"
    }
}

// MARK: - AccuElevation
struct AccuValueWrapper: Codable {
    let metric: AccuValue?
    let imperial: AccuValue?

    enum CodingKeys: String, CodingKey {
        case metric = "Metric"
        case imperial = "Imperial"
    }
}

// MARK: - AccuValue
struct AccuValue: Codable {
    let value: Double
    let unit: String
    let unitType: Int

    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case unit = "Unit"
        case unitType = "UnitType"
    }
}

// MARK: - AccuTimeZone
struct AccuTimeZone: Codable {
    let code: String
    let name: String
    let gmtOffset: Int
    let isDaylightSaving: Bool

    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case name = "Name"
        case gmtOffset = "GmtOffset"
        case isDaylightSaving = "IsDaylightSaving"
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accuCurrentResult = try? newJSONDecoder().decode(AccuCurrentResult.self, from: jsonData)

import Foundation

// MARK: - AccuCurrentResult
struct AccuCurrentResult: Codable {
    let epochTime: Int
    let weatherText: String
    let weatherIcon: Int
    let hasPrecipitation: Bool
    let precipitationType: String?
    let isDayTime: Bool
    let temperature: AccuValueWrapper
    let realFeelTemperature: AccuValueWrapper?
    let realFeelTemperatureShade: AccuValueWrapper?
    let relativeHumidity: Int?
    let indoorRelativeHumidity: Int?
    let dewPoint: AccuValueWrapper?
    let wind: AccuWind?
    let windGust: AccuWindGust?
    let uvIndex: Int?
    let uvIndexText: String?
    let visibility: AccuValueWrapper
    let obstructionsToVisibility: String
    let cloudCover: Int
    let ceiling: AccuValueWrapper
    let pressure: AccuValueWrapper
    let pressureTendency: AccuPressureTendency
    let past24HourTemperatureDeparture: AccuValueWrapper
    let apparentTemperature: AccuValueWrapper
    let windChillTemperature: AccuValueWrapper
    let wetBulbTemperature: AccuValueWrapper
    let precip1Hr: AccuValueWrapper
    let precipitationSummary: [String: AccuValueWrapper]
    let temperatureSummary: AccuTemperatureSummary
    let mobileLink: String
    let link: String

    enum CodingKeys: String, CodingKey {
        case epochTime = "EpochTime"
        case weatherText = "WeatherText"
        case weatherIcon = "WeatherIcon"
        case hasPrecipitation = "HasPrecipitation"
        case precipitationType = "PrecipitationType"
        case isDayTime = "IsDayTime"
        case temperature = "Temperature"
        case realFeelTemperature = "RealFeelTemperature"
        case realFeelTemperatureShade = "RealFeelTemperatureShade"
        case relativeHumidity = "RelativeHumidity"
        case indoorRelativeHumidity = "IndoorRelativeHumidity"
        case dewPoint = "DewPoint"
        case wind = "Wind"
        case windGust = "WindGust"
        case uvIndex = "UVIndex"
        case uvIndexText = "UVIndexText"
        case visibility = "Visibility"
        case obstructionsToVisibility = "ObstructionsToVisibility"
        case cloudCover = "CloudCover"
        case ceiling = "Ceiling"
        case pressure = "Pressure"
        case pressureTendency = "PressureTendency"
        case past24HourTemperatureDeparture = "Past24HourTemperatureDeparture"
        case apparentTemperature = "ApparentTemperature"
        case windChillTemperature = "WindChillTemperature"
        case wetBulbTemperature = "WetBulbTemperature"
        case precip1Hr = "Precip1hr"
        case precipitationSummary = "PrecipitationSummary"
        case temperatureSummary = "TemperatureSummary"
        case mobileLink = "MobileLink"
        case link = "Link"
    }
}

// MARK: - AccuPressureTendency
struct AccuPressureTendency: Codable {
    let localizedText: String
    let code: String

    enum CodingKeys: String, CodingKey {
        case localizedText = "LocalizedText"
        case code = "Code"
    }
}

// MARK: - AccuTemperatureSummary
struct AccuTemperatureSummary: Codable {
    let past6HourRange: AccuPastHourRange
    let past12HourRange: AccuPastHourRange
    let past24HourRange: AccuPastHourRange

    enum CodingKeys: String, CodingKey {
        case past6HourRange = "Past6HourRange"
        case past12HourRange = "Past12HourRange"
        case past24HourRange = "Past24HourRange"
    }
}

// MARK: - AccuPastHourRange
struct AccuPastHourRange: Codable {
    let minimum: AccuValueWrapper
    let maximum: AccuValueWrapper

    enum CodingKeys: String, CodingKey {
        case minimum = "Minimum"
        case maximum = "Maximum"
    }
}

// MARK: - AccuWind
struct AccuWind: Codable {
    let direction: AccuDirection
    let speed: AccuValueWrapper?

    enum CodingKeys: String, CodingKey {
        case direction = "Direction"
        case speed = "Speed"
    }
}

// MARK: - AccuDirection
struct AccuDirection: Codable {
    let degrees: Int
    let localized: String
    let english: String

    enum CodingKeys: String, CodingKey {
        case degrees = "Degrees"
        case localized = "Localized"
        case english = "English"
    }
}

// MARK: - AccuWindGust
struct AccuWindGust: Codable {
    let speed: AccuValueWrapper?

    enum CodingKeys: String, CodingKey {
        case speed = "Speed"
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accuDailyResult = try? newJSONDecoder().decode(AccuDailyResult.self, from: jsonData)

import Foundation

// MARK: - AccuDailyResult
struct AccuDailyResult: Codable {
    let headline: AccuHeadline
    let dailyForecasts: [AccuDailyForecast]

    enum CodingKeys: String, CodingKey {
        case headline = "Headline"
        case dailyForecasts = "DailyForecasts"
    }
}

// MARK: - AccuDailyForecast
struct AccuDailyForecast: Codable {
    let epochDate: Int
    let sun: AccuSun?
    let moon: AccuMoon?
    let temperature: AccuUnitValueRange
    let realFeelTemperature: AccuUnitValueRange?
    let realFeelTemperatureShade: AccuUnitValueRange?
    let hoursOfSun: Double?
    let degreeDaySummary: AccuDegreeDaySummary?
    let airAndPollen: [AccuAirAndPollen]?
    let day: AccuHalfDay
    let night: AccuHalfDay
    let sources: [String]
    let mobileLink: String
    let link: String

    enum CodingKeys: String, CodingKey {
        case epochDate = "EpochDate"
        case sun = "Sun"
        case moon = "Moon"
        case temperature = "Temperature"
        case realFeelTemperature = "RealFeelTemperature"
        case realFeelTemperatureShade = "RealFeelTemperatureShade"
        case hoursOfSun = "HoursOfSun"
        case degreeDaySummary = "DegreeDaySummary"
        case airAndPollen = "AirAndPollen"
        case day = "Day"
        case night = "Night"
        case sources = "Sources"
        case mobileLink = "MobileLink"
        case link = "Link"
    }
}

// MARK: - AccuAirAndPollen
struct AccuAirAndPollen: Codable {
    let name: String
    let value: Int
    let category: String
    let categoryValue: Int
    let type: String?

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case value = "Value"
        case category = "Category"
        case categoryValue = "CategoryValue"
        case type = "Type"
    }
}

// MARK: - AccuHalfDay
struct AccuHalfDay: Codable {
    let icon: Int
    let iconPhrase: String
    let hasPrecipitation: Bool
    let shortPhrase: String?
    let longPhrase: String?
    let precipitationProbability: Double?
    let thunderstormProbability: Double?
    let rainProbability: Double?
    let snowProbability: Double?
    let iceProbability: Double?
    let wind: AccuWind?
    let windGust: AccuWind?
    let totalLiquid: AccuUnitValue
    let rain: AccuUnitValue
    let snow: AccuUnitValue
    let ice: AccuUnitValue
    let hoursOfPrecipitation: Double
    let hoursOfRain: Double
    let hoursOfSnow: Int
    let hoursOfIce: Int
    let cloudCover: Int
    let evapotranspiration: AccuUnitValue
    let solarIrradiance: AccuUnitValue
    let precipitationType: String?
    let precipitationIntensity: String?

    enum CodingKeys: String, CodingKey {
        case icon = "Icon"
        case iconPhrase = "IconPhrase"
        case hasPrecipitation = "HasPrecipitation"
        case shortPhrase = "ShortPhrase"
        case longPhrase = "LongPhrase"
        case precipitationProbability = "PrecipitationProbability"
        case thunderstormProbability = "ThunderstormProbability"
        case rainProbability = "RainProbability"
        case snowProbability = "SnowProbability"
        case iceProbability = "IceProbability"
        case wind = "Wind"
        case windGust = "WindGust"
        case totalLiquid = "TotalLiquid"
        case rain = "Rain"
        case snow = "Snow"
        case ice = "Ice"
        case hoursOfPrecipitation = "HoursOfPrecipitation"
        case hoursOfRain = "HoursOfRain"
        case hoursOfSnow = "HoursOfSnow"
        case hoursOfIce = "HoursOfIce"
        case cloudCover = "CloudCover"
        case evapotranspiration = "Evapotranspiration"
        case solarIrradiance = "SolarIrradiance"
        case precipitationType = "PrecipitationType"
        case precipitationIntensity = "PrecipitationIntensity"
    }
}

// MARK: - AccuPrecipitation
struct AccuUnitValue: Codable {
    let value: Double
    let unit: String
    let unitType: Int

    enum CodingKeys: String, CodingKey {
        case value = "Value"
        case unit = "Unit"
        case unitType = "UnitType"
    }
}

// MARK: - AccuDailyWind
struct AccuDailyWind: Codable {
    let speed: AccuUnitValue
    let direction: AccuDailyDirection

    enum CodingKeys: String, CodingKey {
        case speed = "Speed"
        case direction = "Direction"
    }
}

// MARK: - AccuDailyDirection
struct AccuDailyDirection: Codable {
    let degrees: Int
    let localized: String
    let english: String

    enum CodingKeys: String, CodingKey {
        case degrees = "Degrees"
        case localized = "Localized"
        case english = "English"
    }
}

// MARK: - DegreeDaySummary
struct AccuDegreeDaySummary: Codable {
    let heating: AccuUnitValue
    let cooling: AccuUnitValue

    enum CodingKeys: String, CodingKey {
        case heating = "Heating"
        case cooling = "Cooling"
    }
}

// MARK: - AccuMoon
struct AccuMoon: Codable {
    let epochRise: Int?
    let epochSet: Int?
    let phase: String?
    let age: Int?

    enum CodingKeys: String, CodingKey {
        case epochRise = "EpochRise"
        case epochSet = "EpochSet"
        case phase = "Phase"
        case age = "Age"
    }
}

// MARK: - AccuUnitValueRange
struct AccuUnitValueRange: Codable {
    let minimum: AccuUnitValue
    let maximum: AccuUnitValue

    enum CodingKeys: String, CodingKey {
        case minimum = "Minimum"
        case maximum = "Maximum"
    }
}

// MARK: - Sun
struct AccuSun: Codable {
    let epochRise: Int?
    let epochSet: Int?

    enum CodingKeys: String, CodingKey {
        case epochRise = "EpochRise"
        case epochSet = "EpochSet"
    }
}

// MARK: - AccuHeadline
struct AccuHeadline: Codable {
    let severity: Int
    let text: String
    let category: String
    let mobileLink: String
    let link: String

    enum CodingKeys: String, CodingKey {
        case severity = "Severity"
        case text = "Text"
        case category = "Category"
        case mobileLink = "MobileLink"
        case link = "Link"
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accuHourlyResult = try? newJSONDecoder().decode(AccuHourlyResult.self, from: jsonData)

import Foundation

// MARK: - AccuHourlyResult
struct AccuHourlyResult: Codable {
    let epochDateTime: Int
    let weatherIcon: Int
    let iconPhrase: String
    let hasPrecipitation: Bool
    let isDaylight: Bool
    let temperature: AccuUnitValue
    let precipitationProbability: Double?
    let mobileLink: String
    let link: String

    enum CodingKeys: String, CodingKey {
        case epochDateTime = "EpochDateTime"
        case weatherIcon = "WeatherIcon"
        case iconPhrase = "IconPhrase"
        case hasPrecipitation = "HasPrecipitation"
        case isDaylight = "IsDaylight"
        case temperature = "Temperature"
        case precipitationProbability = "PrecipitationProbability"
        case mobileLink = "MobileLink"
        case link = "Link"
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accuMinutelyResult = try? newJSONDecoder().decode(AccuMinutelyResult.self, from: jsonData)

import Foundation

// MARK: - AccuMinutelyResult
struct AccuMinutelyResult: Codable {
    let summary: AccuMinutelyPurpleSummary
    let summaries: [AccuMinutelySummaryElement]
    let intervals: [AccuInterval]
    let mobileLink: String
    let link: String

    enum CodingKeys: String, CodingKey {
        case summary = "Summary"
        case summaries = "Summaries"
        case intervals = "Intervals"
        case mobileLink = "MobileLink"
        case link = "Link"
    }
}

// MARK: - AccuInterval
struct AccuInterval: Codable {
    let startEpochDateTime: Int
    let minute: Int
    let dbz: Int
    let shortPhrase: ShortPhrase
    let iconCode: Int
    let cloudCover: Int
    let lightningRate: Int

    enum CodingKeys: String, CodingKey {
        case startEpochDateTime = "StartEpochDateTime"
        case minute = "Minute"
        case dbz = "Dbz"
        case shortPhrase = "ShortPhrase"
        case iconCode = "IconCode"
        case cloudCover = "CloudCover"
        case lightningRate = "LightningRate"
    }
}

enum ShortPhrase: String, Codable {
    case noPrecipitation = "No Precipitation"
}

// MARK: - AccuMinutelySummaryElement
struct AccuMinutelySummaryElement: Codable {
    let startMinute: Int
    let endMinute: Int
    let countMinute: Int
    let minuteText: String
    let minutesText: String
    let widgetPhrase: String
    let shortPhrase: String
    let briefPhrase: String
    let longPhrase: String
    let iconCode: Int

    enum CodingKeys: String, CodingKey {
        case startMinute = "StartMinute"
        case endMinute = "EndMinute"
        case countMinute = "CountMinute"
        case minuteText = "MinuteText"
        case minutesText = "MinutesText"
        case widgetPhrase = "WidgetPhrase"
        case shortPhrase = "ShortPhrase"
        case briefPhrase = "BriefPhrase"
        case longPhrase = "LongPhrase"
        case iconCode = "IconCode"
    }
}

// MARK: - AccuMinutelyPurpleSummary
struct AccuMinutelyPurpleSummary: Codable {
    let phrase: String
    let phrase60: String
    let widgetPhrase: String
    let shortPhrase: String
    let briefPhrase: String
    let longPhrase: String
    let iconCode: Int

    enum CodingKeys: String, CodingKey {
        case phrase = "Phrase"
        case phrase60 = "Phrase_60"
        case widgetPhrase = "WidgetPhrase"
        case shortPhrase = "ShortPhrase"
        case briefPhrase = "BriefPhrase"
        case longPhrase = "LongPhrase"
        case iconCode = "IconCode"
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accuAirQualityResult = try? newJSONDecoder().decode(AccuAirQualityResult.self, from: jsonData)

import Foundation

// MARK: - AccuAirQualityResult
struct AccuAirQualityResult: Codable {
    let epochDate: Int
    let index: Int
    let particulateMatter25: Double?
    let particulateMatter10: Double?
    let ozone: Double?
    let carbonMonoxide: Double?
    let nitrogenMonoxide: Double?
    let nitrogenDioxide: Double?
    let sulfurDioxide: Double?
    let lead: Double?
    let source: String

    enum CodingKeys: String, CodingKey {
        case epochDate = "EpochDate"
        case index = "Index"
        case particulateMatter25 = "ParticulateMatter2_5"
        case particulateMatter10 = "ParticulateMatter10"
        case ozone = "Ozone"
        case carbonMonoxide = "CarbonMonoxide"
        case nitrogenMonoxide = "NitrogenMonoxide"
        case nitrogenDioxide = "NitrogenDioxide"
        case sulfurDioxide = "SulfurDioxide"
        case lead = "Lead"
        case source = "Source"
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accuAlertResult = try? newJSONDecoder().decode(AccuAlertResult.self, from: jsonData)

import Foundation

// MARK: - AccuAlertResultElement
struct AccuAlertResult: Codable {
    let countryCode: String
    let alertID: Int
    let accuAlertResultDescription: AccuAlertTion
    let category: String
    let priority: Int
    let type: String
    let typeID: String
    let level: String
    let color: AccuAlertColor
    let source: String
    let sourceId: Int
    let area: [AccuAlertArea]
    let haveReadyStatements: Bool
    let mobileLink: String
    let link: String

    enum CodingKeys: String, CodingKey {
        case countryCode = "CountryCode"
        case alertID = "AlertID"
        case accuAlertResultDescription = "Description"
        case category = "Category"
        case priority = "Priority"
        case type = "Type"
        case typeID = "TypeID"
        case level = "Level"
        case color = "Color"
        case source = "Source"
        case sourceId = "SourceId"
        case area = "Area"
        case haveReadyStatements = "HaveReadyStatements"
        case mobileLink = "MobileLink"
        case link = "Link"
    }
}

// MARK: - AccuAlertTion
struct AccuAlertTion: Codable {
    let localized: String
    let english: String

    enum CodingKeys: String, CodingKey {
        case localized = "Localized"
        case english = "English"
    }
}

// MARK: - AccuAlertArea
struct AccuAlertArea: Codable {
    let name: String
    let epochStartTime: Int
    let epochEndTime: Int
    let lastAction: AccuAlertTion
    let text: String
    let languageCode: String
    let summary: String

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case epochStartTime = "EpochStartTime"
        case epochEndTime = "EpochEndTime"
        case lastAction = "LastAction"
        case text = "Text"
        case languageCode = "LanguageCode"
        case summary = "Summary"
    }
}

// MARK: - AccuAlertColor
struct AccuAlertColor: Codable {
    let name: String
    let red: Int
    let green: Int
    let blue: Int
    let hex: String

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case red = "Red"
        case green = "Green"
        case blue = "Blue"
        case hex = "Hex"
    }
}
