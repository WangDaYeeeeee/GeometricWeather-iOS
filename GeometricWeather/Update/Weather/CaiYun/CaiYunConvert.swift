//
//  CaiYunConvert.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/20.
//

import Foundation
import GeometricWeatherBasic

func caiYunGenerateLocationsByAccuSource(
    _ from: Array<AccuLocationResult>,
    src: Location? = nil,
    zipCode: String? = nil
) -> Array<Location> {
    var locations = [Location]()
    
    for result in from {
        locations.append(
            caiYunGenerateLocationByAccuSource(
                result,
                src: src,
                zipCode: zipCode
            )
        )
    }
    
    return locations
}

func caiYunGenerateLocationByAccuSource(
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
        weatherSource: .caiYun,
        currentPosition: src?.currentPosition ?? false,
        residentPosition: src?.residentPosition ?? false
    )
}

func generateWeather(
    location: Location,
    weatherResult: CaiYunWeatherResult,
    historyResult: AccuCurrentResult,
    moonResult: AccuDailyResult
) -> Weather? {
    return Weather(
        base: Base(
            cityId: location.cityId,
            timeStamp: Date().timeIntervalSince1970
        ),
        current: Current(
            weatherText: getWeatherText(weatherResult.result.realtime.skycon),
            weatherCode: getWeatherCode(weatherResult.result.realtime.skycon),
            temperature: Temperature(
                temperature: Int(weatherResult.result.realtime.temperature),
                realFeelTemperature: Int(weatherResult.result.realtime.apparentTemperature)
            ),
            precipitationIntensity: weatherResult.result.realtime.precipitation.local.intensity,
            precipitationProbability: nil,
            wind: Wind(
                direction: getWindDirectionText(
                    weatherResult.result.realtime.wind.direction
                ),
                degree: WindDegree(
                    degree: weatherResult.result.realtime.wind.direction,
                    noDirection: false
                ),
                speed: weatherResult.result.realtime.wind.speed,
                level: getWindLevelInt(
                    speed: weatherResult.result.realtime.wind.speed
                )
            ),
            uv: UV(
                index: Int(weatherResult.result.realtime.lifeIndex.ultraviolet.index),
                level: weatherResult.result.realtime.lifeIndex.ultraviolet.desc,
                description: nil
            ),
            airQuality: AirQuality(
                aqiLevel: weatherResult.result.realtime.airQuality.aqi.usa == 0
                ? nil
                : getAqiQualityInt(
                    index: Int(weatherResult.result.realtime.airQuality.aqi.usa)
                ),
                aqiIndex: weatherResult.result.realtime.airQuality.aqi.usa == 0
                ? nil
                : Int(weatherResult.result.realtime.airQuality.aqi.usa),
                pm25: weatherResult.result.realtime.airQuality.pm25 == 0
                ? nil
                : weatherResult.result.realtime.airQuality.pm25,
                pm10: weatherResult.result.realtime.airQuality.pm10 == 0
                ? nil
                : weatherResult.result.realtime.airQuality.pm10,
                so2: weatherResult.result.realtime.airQuality.so2 == 0
                ? nil
                : weatherResult.result.realtime.airQuality.so2,
                no2: weatherResult.result.realtime.airQuality.no2 == 0
                ? nil
                : weatherResult.result.realtime.airQuality.no2,
                o3: weatherResult.result.realtime.airQuality.o3 == 0
                ? nil
                : weatherResult.result.realtime.airQuality.o3,
                co: weatherResult.result.realtime.airQuality.co == 0
                ? nil
                : weatherResult.result.realtime.airQuality.co
            ),
            relativeHumidity: weatherResult.result.realtime.humidity * 100.0,
            pressure: weatherResult.result.realtime.pressure / 100.0,
            visibility: weatherResult.result.realtime.visibility,
            dewPoint: nil,
            cloudCover: nil,
            ceiling: nil,
            dailyForecast: weatherResult.result.hourly.hourlyDescription,
            hourlyForecast: weatherResult.result.forecastKeypoint
        ),
        yesterday: History(
            time: TimeInterval(historyResult.epochTime - 24 * 60 * 60),
            daytimeTemperature: Int.toInt(
                historyResult.temperatureSummary.past24HourRange.maximum.metric?.value
            ),
            nighttimeTemperature: Int.toInt(
                historyResult.temperatureSummary.past24HourRange.minimum.metric?.value
            )
        ),
        dailyForecasts: getDailyList(
            weatherResult,
            moonResult: moonResult,
            timezone: location.timezone
        ),
        hourlyForecasts: getHourlyList(weatherResult),
        minutelyForecast: Minutely(
            beginTime: Date().timeIntervalSince1970 + Double(
                location.timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
            ),
            endTime: Date().timeIntervalSince1970 + Double(
                location.timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
            ) + 2 * 60 * 60,
            precipitationIntensityInPercentage: weatherResult.result.minutely.precipitation2H
        ),
        alerts: getAlertList(weatherResult)
    )
}

private func getWeatherText(_ skycon: String) -> String {
    if skycon.contains("CLEAR") {
        return NSLocalizedString("weather_clear", comment: "")
    }
    if skycon.contains("PARTLY_CLOUDY") {
        return NSLocalizedString("weather_partly_cloudy", comment: "")
    }
    if skycon.contains("CLOUDY") {
        return NSLocalizedString("weather_cloudy", comment: "")
    }
    if skycon.contains("HAZE") {
        return NSLocalizedString("weather_haze", comment: "")
    }
    if skycon == "LIGHT_RAIN" {
        return NSLocalizedString("weather_light_rain", comment: "")
    }
    if skycon == "MODERATE_RAIN" {
        return NSLocalizedString("weather_moderate_rain", comment: "")
    }
    if skycon.contains("RAIN") {
        return NSLocalizedString("weather_heavy_rain", comment: "")
    }
    if skycon.contains("FOG") {
        return NSLocalizedString("weather_fog", comment: "")
    }
    if skycon == "LIGHT_SNOW" {
        return NSLocalizedString("weather_light_snow", comment: "")
    }
    if skycon == "MODERATE_SNOW" {
        return NSLocalizedString("weather_moderate_snow", comment: "")
    }
    if skycon.contains("SNOW") {
        return NSLocalizedString("weather_heavy_snow", comment: "")
    }
    if skycon.contains("DUST") {
        return NSLocalizedString("weather_dust", comment: "")
    }
    if skycon.contains("SAND") {
        return NSLocalizedString("weather_sand", comment: "")
    }
    return NSLocalizedString("weather_wind", comment: "")
}

// TODO: wind direction description.
private func getWindDirectionText(_ direction: Double) -> String? {
    let d = direction.truncatingRemainder(dividingBy: 360.0)
    
    if 348.75 < d || d <= 11.25 {
        return NSLocalizedString("wind_direction_n", comment: "")
    }
    if 11.25 < d && d <= 33.75 {
        return NSLocalizedString("wind_direction_nne", comment: "")
    }
    if 33.75 < d && d <= 56.25 {
        return NSLocalizedString("wind_direction_ne", comment: "")
    }
    if 56.25 < d && d <= 78.75 {
        return NSLocalizedString("wind_direction_ene", comment: "")
    }
    if 78.75 < d && d <= 101.25 {
        return NSLocalizedString("wind_direction_e", comment: "")
    }
    if 101.25 < d && d <= 123.75 {
        return NSLocalizedString("wind_direction_ese", comment: "")
    }
    if 123.75 < d && d <= 146.25 {
        return NSLocalizedString("wind_direction_se", comment: "")
    }
    if 146.25 < d && d <= 168.75 {
        return NSLocalizedString("wind_direction_sse", comment: "")
    }
    if 168.75 < d && d <= 191.25 {
        return NSLocalizedString("wind_direction_s", comment: "")
    }
    if 191.25 < d && d <= 213.75 {
        return NSLocalizedString("wind_direction_ssw", comment: "")
    }
    if 213.75 < d && d <= 236.25 {
        return NSLocalizedString("wind_direction_sw", comment: "")
    }
    if 236.25 < d && d <= 258.75 {
        return NSLocalizedString("wind_direction_wsw", comment: "")
    }
    if 258.75 < d && d <= 281.25 {
        return NSLocalizedString("wind_direction_w", comment: "")
    }
    if 281.25 < d && d <= 303.75 {
        return NSLocalizedString("wind_direction_wnw", comment: "")
    }
    if 303.75 < d && d <= 326.25 {
        return NSLocalizedString("wind_direction_nw", comment: "")
    }
    return NSLocalizedString("wind_direction_nnw", comment: "")
}

private func getWeatherCode(_ skycon: String) -> WeatherCode {
    if skycon.contains("CLEAR") {
        return .clear
    }
    if skycon.contains("PARTLY_CLOUDY") {
        return .partlyCloudy
    }
    if skycon.contains("CLOUDY") {
        return .cloudy
    }
    if skycon.contains("HAZE") {
        return .haze
    }
    if skycon == "LIGHT_RAIN" {
        return .rain(.light)
    }
    if skycon == "MODERATE_RAIN" {
        return .rain(.middle)
    }
    if skycon.contains("RAIN") {
        return .rain(.heavy)
    }
    if skycon.contains("FOG") {
        return .fog
    }
    if skycon == "LIGHT_SNOW" {
        return .snow(.light)
    }
    if skycon == "MODERATE_SNOW" {
        return .snow(.middle)
    }
    if skycon.contains("SNOW") {
        return .snow(.heavy)
    }
    if skycon.contains("DUST") {
        return .haze
    }
    return .wind
}

private func getDailyList(
    _ weatherResult: CaiYunWeatherResult,
    moonResult: AccuDailyResult,
    timezone: TimeZone
) -> [Daily] {
    var list = [Daily]()
    for i in 0 ..< weatherResult.result.daily.temperature.count {
        let forecast = moonResult.dailyForecasts.get(i)
        
        list.append(
            Daily(
                time: getDate(
                    weatherResult.result.daily.temperature[i].date
                ).timeIntervalSince1970,
                day: HalfDay(
                    weatherText: getWeatherText(
                        weatherResult.result.daily.skycon08H20H[i].value
                    ),
                    weatherPhase: getWeatherText(
                        weatherResult.result.daily.skycon08H20H[i].value
                    ),
                    weatherCode: getWeatherCode(
                        weatherResult.result.daily.skycon08H20H[i].value
                    ),
                    temperature: Temperature(
                        temperature: Int(weatherResult.result.daily.temperature[i].max)
                    ),
                    precipitationTotal: nil,
                    precipitationIntensity: weatherResult.result.daily.precipitation[i].avg,
                    precipitationProbability: nil,
                    wind: Wind(
                        direction: getWindDirectionText(
                            weatherResult.result.daily.wind[i].avg.direction
                        ),
                        degree: WindDegree(
                            degree: weatherResult.result.daily.wind[i].avg.direction,
                            noDirection: false
                        ),
                        speed: weatherResult.result.daily.wind[i].avg.speed,
                        level: getWindLevelInt(
                            speed: weatherResult.result.daily.wind[i].avg.speed
                        )
                    ),
                    cloudCover: nil
                ),
                night: HalfDay(
                    weatherText: getWeatherText(
                        weatherResult.result.daily.skycon20H32H[i].value
                    ),
                    weatherPhase: getWeatherText(
                        weatherResult.result.daily.skycon20H32H[i].value
                    ),
                    weatherCode: getWeatherCode(
                        weatherResult.result.daily.skycon20H32H[i].value
                    ),
                    temperature: Temperature(
                        temperature: Int(weatherResult.result.daily.temperature[i].min)
                    ),
                    precipitationTotal: nil,
                    precipitationIntensity: weatherResult.result.daily.precipitation[i].avg,
                    precipitationProbability: nil,
                    wind: Wind(
                        direction: getWindDirectionText(
                            weatherResult.result.daily.wind[i].avg.direction
                        ),
                        degree: WindDegree(
                            degree: weatherResult.result.daily.wind[i].avg.direction,
                            noDirection: false
                        ),
                        speed: weatherResult.result.daily.wind[i].avg.speed,
                        level: getWindLevelInt(
                            speed: weatherResult.result.daily.wind[i].avg.speed
                        )
                    ),
                    cloudCover: nil
                ),
                sun: Astro(
                    riseTime: forecast?.sun?.epochRise == nil ? nil : Double(
                        forecast!.sun!.epochRise! + (
                            timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                        )
                    ),
                    setTime: forecast?.sun?.epochSet == nil ? nil : Double(
                        forecast!.sun!.epochSet! + (
                            timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                        )
                    )
                ),
                moon: Astro(
                    riseTime: forecast?.moon?.epochRise == nil ? nil : Double(
                        forecast!.moon!.epochRise! + (
                            timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                        )
                    ),
                    setTime: forecast?.moon?.epochSet == nil ? nil : Double(
                        forecast!.moon!.epochSet! + (
                            timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                        )
                    )
                ),
                moonPhase: MoonPhase(
                    angle: getMoonPhaseAngle(phase: forecast?.moon?.phase ?? ""),
                    description: forecast?.moon?.phase
                ),
                airQuality: AirQuality(
                    aqiLevel: weatherResult.result.daily.airQuality.aqi[i].avg.usa == 0
                    ? nil
                    : getAqiQualityInt(
                        index: Int(weatherResult.result.daily.airQuality.aqi[i].avg.usa)
                    ),
                    aqiIndex: weatherResult.result.daily.airQuality.aqi[i].avg.usa == 0
                    ? nil
                    : Int(weatherResult.result.daily.airQuality.aqi[i].avg.usa),
                    pm25: weatherResult.result.daily.airQuality.pm25[i].avg == 0
                    ? nil
                    : weatherResult.result.daily.airQuality.pm25[i].avg,
                    pm10: nil,
                    so2: nil,
                    no2: nil,
                    o3: nil,
                    co: nil
                ),
                pollen: getDailyPollen(array: forecast?.airAndPollen ?? []),
                uv: UV(
                    index: Int(
                        weatherResult.result.daily.lifeIndex.ultraviolet[0].index
                    ),
                    level: weatherResult.result.daily.lifeIndex.ultraviolet[0].desc,
                    description: nil
                ),
                hoursOfSun: nil
            )
        )
    }
    return list
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

private func getHourlyList(
    _ weatherResult: CaiYunWeatherResult
) -> [Hourly] {
    var list = [Hourly]()
    for i in 0 ..< weatherResult.result.hourly.temperature.count {
        list.append(
            Hourly(
                time: getDate(
                    weatherResult.result.hourly.temperature[i].datetime
                ).timeIntervalSince1970,
                daylight: isDaylight(
                    getDate(
                        weatherResult.result.hourly.temperature[i].datetime
                    ),
                    sunrise: getDate(
                        weatherResult.result.daily.astro[0].date.replacingOccurrences(
                            of: "T00:00",
                            with: "T\(weatherResult.result.daily.astro[0].sunrise.time)"
                        )
                    ),
                    sunset: getDate(
                        weatherResult.result.daily.astro[0].date.replacingOccurrences(
                            of: "T00:00",
                            with: "T\(weatherResult.result.daily.astro[0].sunset.time)"
                        )
                    )
                ),
                weatherText: getWeatherText(
                    weatherResult.result.hourly.skycon[i].value
                ),
                weatherCode: getWeatherCode(
                    weatherResult.result.hourly.skycon[i].value
                ),
                temperature: Temperature(
                    temperature: Int(weatherResult.result.hourly.temperature[i].value)
                ),
                precipitationIntensity: weatherResult.result.hourly.precipitation[i].value,
                precipitationProbability: nil,
                wind: Wind(
                    direction: getWindDirectionText(
                        weatherResult.result.hourly.wind[i].direction
                    ),
                    degree: WindDegree(
                        degree: weatherResult.result.hourly.wind[i].direction,
                        noDirection: false
                    ),
                    speed: weatherResult.result.hourly.wind[i].speed,
                    level: getWindLevelInt(
                        speed: weatherResult.result.hourly.wind[i].speed
                    )
                )
            )
        )
    }
    return list
}

private func getAlertList(
    _ weatherResult: CaiYunWeatherResult
) -> [WeatherAlert] {
    var list = [WeatherAlert]()
    if let content = weatherResult.result.alert?.content {
        for i in 0 ..< content.count {
            list.append(
                WeatherAlert(
                    alertId: Int64(content[i].pubtimestamp),
                    time: TimeInterval(content[i].pubtimestamp),
                    description: content[i].title,
                    content: content[i].alertDescription,
                    type: content[i].code,
                    priority: 0,
                    color: 0
                )
            )
        }
    }
    return list
}

private func getDate(_ text: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
    return formatter.date(
        from: String(
            text[..<text.index(text.endIndex, offsetBy: -6)]
        )
    ) ?? Date()
}

private func isDaylight(
    _ date: Date,
    sunrise: Date,
    sunset: Date
) -> Bool {
    let targetTime = Calendar.current.component(
        .hour,
        from: date
    ) * 60 + Calendar.current.component(
        .minute,
        from: date
    )
    let sunriseTime = Calendar.current.component(
        .hour,
        from: sunrise
    ) * 60 + Calendar.current.component(
        .minute,
        from: sunrise
    )
    let sunsetTime = Calendar.current.component(
        .hour,
        from: sunset
    ) * 60 + Calendar.current.component(
        .minute,
        from: sunset
    )
    
    return sunriseTime <= targetTime && targetTime < sunsetTime
}
