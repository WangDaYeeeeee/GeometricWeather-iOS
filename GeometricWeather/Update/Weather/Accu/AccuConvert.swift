//
//  AccuConvert.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation
import SwiftUI

func generateLocations(
    _ from: Array<AccuLocationResult>,
    src: Location? = nil,
    zipCode: String? = nil
) -> Array<Location> {
    var locations = [Location]()
    
    for result in from {
        locations.append(
            generateLocation(
                result,
                src: src,
                zipCode: zipCode
            )
        )
    }
    
    return locations
}

func generateLocation(
    _ from: AccuLocationResult,
    src: Location? = nil,
    zipCode: String? = nil
) -> Location {
    return Location(
        cityId: from.key,
        latitude: from.geoPosition.latitude,
        longitude: from.geoPosition.longitude,
        timezone: TimeZone(identifier: from.timeZone.name) ?? TimeZone.current,
        country: from.country.localizedName,
        province: from.administrativeArea.localizedName,
        city: "\(from.localizedName)\(zipCode == nil ? "" : "(\(zipCode!))")",
        district: "",
        weather: nil,
        weatherSource: WeatherSource["weather_source_accu"],
        currentPosition: src?.currentPosition ?? false,
        residentPosition: src?.residentPosition ?? false
    )
}

func generateWeather(
    location: Location,
    currentResult: AccuCurrentResult,
    dailyResult: AccuDailyResult,
    hourlyResults: [AccuHourlyResult],
    alertResults: [AccuAlertResult]?,
    airQualityResult: AccuAirQualityResult?
) -> Weather? {
    return Weather(
        base: Base(
            cityId: location.cityId,
            timeStamp: Date().timeIntervalSince1970,
            publishTime: Double(
                currentResult.epochTime + (
                    location.timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                )
            ),
            updateTime: Date().timeIntervalSince1970
        ),
        current: Current(
            weatherText: currentResult.weatherText,
            weatherCode: getWeatherCode(currentResult.weatherIcon),
            temperature: Temperature(
                temperature: Int(currentResult.temperature.metric?.value ?? 0),
                realFeelTemperature: Int.toInt(currentResult.realFeelTemperature?.metric?.value),
                realFeelShaderTemperature: Int.toInt(currentResult.realFeelTemperatureShade?.metric?.value),
                apparentTemperature: Int.toInt(currentResult.apparentTemperature.metric?.value),
                windChillTemperature: Int.toInt(currentResult.windChillTemperature.metric?.value),
                wetBulbTemperature: Int.toInt(currentResult.wetBulbTemperature.metric?.value),
                degreeDayTemperature: nil
            ),
            precipitation: Precipitation(
                total: Double(currentResult.precip1Hr.metric?.value ?? 0)
            ),
            precipitationProbability: 0.0,
            wind: Wind(
                direction: currentResult.wind?.direction.localized ?? "",
                degree: WindDegree(
                    degree: Double(currentResult.wind?.direction.degrees ?? 0),
                    noDirection: currentResult.wind?.direction.degrees == nil
                ),
                speed: currentResult.windGust?.speed?.metric?.value,
                level: getWindLevelInt(
                    speed: currentResult.windGust?.speed?.metric?.value ?? 0
                )
            ),
            uv: UV(
                index: currentResult.uvIndex,
                level: currentResult.uvIndexText,
                description: nil
            ),
            airQuality: AirQuality(
                aqiLevel: getAqiQualityInt(index: airQualityResult?.index ?? 0),
                aqiIndex: airQualityResult?.index,
                pm25: airQualityResult?.particulateMatter25,
                pm10: airQualityResult?.particulateMatter10,
                so2: airQualityResult?.sulfurDioxide,
                no2: airQualityResult?.nitrogenDioxide,
                o3: airQualityResult?.ozone,
                co: airQualityResult?.carbonMonoxide
            ),
            relativeHumidity: currentResult.relativeHumidity == nil ? nil : Double(
                currentResult.relativeHumidity!
            ),
            pressure: Double(currentResult.pressure.metric?.value ?? 0),
            visibility: Double(currentResult.visibility.metric?.value ?? 0),
            dewPoint: Int.toInt(currentResult.dewPoint?.metric?.value ?? 0),
            cloudCover: currentResult.cloudCover,
            ceiling: Int(Double(currentResult.ceiling.metric?.value ?? 0)),
            dailyForecast: dailyResult.headline.text,
            hourlyForecast: nil
        ),
        yesterday: History(
            time: TimeInterval(currentResult.epochTime - 24 * 60 * 60),
            daytimeTemperature: Int.toInt(
                currentResult.temperatureSummary.past24HourRange.maximum.metric?.value
            ),
            nighttimeTemperature: Int.toInt(
                currentResult.temperatureSummary.past24HourRange.minimum.metric?.value
            )
        ),
        dailyForecasts: getDailies(result: dailyResult, timezone: location.timezone),
        hourlyForecasts: getHourlies(results: hourlyResults, timezone: location.timezone),
        alerts: getAlerts(results: alertResults ?? [], timezone: location.timezone)
    )
}

private func getWeatherCode(_ icon: Int) -> WeatherCode {
  if icon == 1 || icon == 2 || icon == 30
      || icon == 33 || icon == 34 {
    return WeatherCode.clear
  } else if icon == 3 || icon == 4 || icon == 6 || icon == 7
      || icon == 35 || icon == 36 || icon == 38 {
    return WeatherCode.partlyCloudy
  } else if icon == 5 || icon == 37 {
    return WeatherCode.haze
  } else if icon == 8 {
    return WeatherCode.cloudy
  } else if icon == 11 {
    return WeatherCode.fog
  } else if icon == 12 || icon == 13 || icon == 14 || icon == 39 || icon == 40 {
      return WeatherCode.rain(.light)
  } else if icon == 18 {
      return WeatherCode.rain(.middle)
  } else if icon == 15 || icon == 16 || icon == 17 || icon == 41 || icon == 42 {
    return WeatherCode.thunderstorm
  } else if icon == 19 || icon == 20 || icon == 21 || icon == 23
      || icon == 31 || icon == 43 || icon == 44 {
      return WeatherCode.snow(.light)
  } else if icon == 22 || icon == 24 {
      return WeatherCode.snow(.middle)
  } else if icon == 25 {
    return WeatherCode.hail
  } else if icon == 26 || icon == 29 {
      return WeatherCode.sleet(.light)
  } else if icon == 32 {
    return WeatherCode.wind
  } else {
    return WeatherCode.cloudy
  }
}

private func convertUnit(_ str: String) -> String {
    if (str.isEmpty) {
        return str
    }

    // precipitation.
    let precipitationUnit = SettingsManager.shared.precipitationUnit
    // cm.
    var s = convertStrUnit(
        str,
        targetUnit: PrecipitationUnit["precipitation_unit_cm"],
        resultUnit: precipitationUnit
    )
    // mm.
    s = convertStrUnit(
        str,
        targetUnit: PrecipitationUnit["precipitation_unit_mm"],
        resultUnit: precipitationUnit
    )
    return s
}

private func convertStrUnit(
    _ str: String,
    targetUnit: PrecipitationUnit,
    resultUnit: PrecipitationUnit
) -> String {
    // TODO: implement.
    return str
}

private func arrayToString(_ array: Array<String>) -> String {
    var b = ""
    for i in 0 ..< array.count {
        b += array[i]
        if i < array.count - 1 {
            b += "-"
        }
    }
    return b
}

private func getAirAndPollen(
    array: Array<AccuAirAndPollen>,
    name: String
) -> AccuAirAndPollen? {
    
    for item in array {
        if (item.name == name) {
            return item
        }
    }
    return nil
}

private func getDailyAirQuality(
    array: Array<AccuAirAndPollen>
) -> AirQuality {
    
    let aqi = getAirAndPollen(
        array: array,
        name: "AirQuality"
    )
    
    return AirQuality(
        aqiLevel: getAqiQualityInt(index: aqi?.value ?? 0),
        aqiIndex: aqi?.value,
        pm25: nil,
        pm10: nil,
        so2: nil,
        no2: nil,
        o3: nil,
        co: nil
    )
}

private func getDailyPollen(
    array: Array<AccuAirAndPollen>
) -> Pollen {
    let grass = getAirAndPollen(array: array, name: "Grass")
    let mold = getAirAndPollen(array: array, name: "Mold")
    let ragweed = getAirAndPollen(array: array, name: "Ragweed")
    let tree = getAirAndPollen(array: array, name: "Tree")
    
    return Pollen(
        grassIndex: grass?.value,
        grassLevel: grass?.categoryValue,
        grassDescription: grass?.category,
        moldIndex: mold?.value,
        moldLevel: mold?.categoryValue,
        moldDescription: mold?.category,
        ragweedIndex: ragweed?.value,
        ragweedLevel: ragweed?.categoryValue,
        ragweedDescription: ragweed?.category,
        treeIndex: tree?.value,
        treeLevel: tree?.categoryValue,
        treeDescription: tree?.category
    )
}

private func getDailyUV(
    array: Array<AccuAirAndPollen>
) -> UV {
    let uv = getAirAndPollen(array: array, name: "UVIndex")

    return UV(
        index: uv?.value,
        level: uv?.category,
        description: nil
    )
}

private func getDailies(
    result: AccuDailyResult,
    timezone: TimeZone
) -> [Daily] {
    var dailies = [Daily]()
    
    for forecast in result.dailyForecasts {
        dailies.append(
            Daily(
                time: Double(forecast.epochDate),
                day: HalfDay(
                    weatherText: forecast.day.longPhrase ?? "",
                    weatherPhase: forecast.day.shortPhrase ?? forecast.day.longPhrase ?? "",
                    weatherCode: getWeatherCode(forecast.day.icon),
                    temperature: Temperature(
                        temperature: Int(forecast.temperature.maximum.value),
                        realFeelTemperature: Int.toInt(forecast.realFeelTemperature?.maximum.value),
                        realFeelShaderTemperature: Int.toInt(forecast.realFeelTemperatureShade?.maximum.value),
                        degreeDayTemperature: Int.toInt(forecast.degreeDaySummary?.heating.value)
                    ),
                    precipitation: Precipitation(
                        total: forecast.day.totalLiquid.value,
                        thunderstorm: nil,
                        rain: forecast.day.rain.value,
                        snow: forecast.day.snow.value,
                        ice: forecast.day.ice.value
                    ),
                    precipitationProbability: forecast.day.precipitationProbability,
                    wind: Wind(
                        direction: forecast.day.wind?.direction.localized ?? "",
                        degree: WindDegree(
                            degree: Double(forecast.day.wind?.direction.degrees ?? 0),
                            noDirection: forecast.day.wind?.direction.degrees == nil
                        ),
                        speed: forecast.day.windGust?.speed?.metric?.value,
                        level: getWindLevelInt(
                            speed: forecast.day.windGust?.speed?.metric?.value ?? 0
                        )
                    ),
                    cloudCover: forecast.day.cloudCover
                ),
                night: HalfDay(
                    weatherText: forecast.night.longPhrase ?? "",
                    weatherPhase: forecast.night.shortPhrase ?? forecast.night.longPhrase ?? "",
                    weatherCode: getWeatherCode(forecast.night.icon),
                    temperature: Temperature(
                        temperature: Int(forecast.temperature.minimum.value),
                        realFeelTemperature: Int.toInt(forecast.realFeelTemperature?.minimum.value),
                        realFeelShaderTemperature: Int.toInt(forecast.realFeelTemperatureShade?.minimum.value),
                        degreeDayTemperature: Int.toInt(forecast.degreeDaySummary?.cooling.value)
                    ),
                    precipitation: Precipitation(
                        total: forecast.night.totalLiquid.value,
                        thunderstorm: nil,
                        rain: forecast.night.rain.value,
                        snow: forecast.night.snow.value,
                        ice: forecast.night.ice.value
                    ),
                    precipitationProbability: forecast.night.precipitationProbability,
                    wind: Wind(
                        direction: forecast.night.wind?.direction.localized ?? "",
                        degree: WindDegree(
                            degree: Double(forecast.night.wind?.direction.degrees ?? 0),
                            noDirection: forecast.night.wind?.direction.degrees == nil
                        ),
                        speed: forecast.night.windGust?.speed?.metric?.value,
                        level: getWindLevelInt(
                            speed: forecast.night.windGust?.speed?.metric?.value ?? 0
                        )
                    ),
                    cloudCover: forecast.night.cloudCover
                ),
                sun: Astro(
                    riseTime: forecast.sun?.epochRise == nil ? nil : Double(
                        forecast.sun!.epochRise! + (
                            timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                        )
                    ),
                    setTime: forecast.sun?.epochSet == nil ? nil : Double(
                        forecast.sun!.epochSet! + (
                            timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                        )
                    )
                ),
                moon: Astro(
                    riseTime: forecast.moon?.epochRise == nil ? nil : Double(
                        forecast.moon!.epochRise! + (
                            timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                        )
                    ),
                    setTime: forecast.moon?.epochSet == nil ? nil : Double(
                        forecast.moon!.epochSet! + (
                            timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                        )
                    )
                ),
                moonPhase: MoonPhase(
                    angle: getMoonPhaseAngle(phase: forecast.moon?.phase ?? ""),
                    description: forecast.moon?.phase
                ),
                airQuality: getDailyAirQuality(array: forecast.airAndPollen ?? []),
                pollen: getDailyPollen(array: forecast.airAndPollen ?? []),
                uv: getDailyUV(array: forecast.airAndPollen ?? []),
                hoursOfSun: forecast.hoursOfSun
            )
        )
    }
    
    return dailies
}

private func getHourlies(
    results: [AccuHourlyResult],
    timezone: TimeZone
) -> [Hourly] {
    var hourlies = [Hourly]()
    
    for result in results {
        hourlies.append(
            Hourly(
                time: Double(
                    result.epochDateTime + (
                        timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                    )
                ),
                daylight: result.isDaylight,
                weatherText: result.iconPhrase,
                weatherCode: getWeatherCode(result.weatherIcon),
                temperature: Temperature(
                    temperature: toInt(result.temperature.value)
                ),
                precipitation: Precipitation(total: nil),
                precipitationProbability: result.precipitationProbability
            )
        )
    }
    
    return hourlies
}

private func getAlerts(
    results: [AccuAlertResult],
    timezone: TimeZone
) -> [Alert] {
    var alerts = [Alert]()
    
    for result in results {
        alerts.append(
            Alert(
                alertId: Int64(result.alertID),
                time: Double(
                    result.area[0].epochStartTime + (
                        timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                    )
                ),
                description: result.accuAlertResultDescription.localized,
                content: result.area[0].text,
                type: result.typeID,
                priority: result.priority,
                color: (result.color.red << 16) + (result.color.green << 8) + result.color.blue
            )
        )
    }
        
    alerts = Alert.deduplicate(alertArray: alerts)
    alerts = Alert.descByTime(alertArray: alerts)
    
    return alerts
}
