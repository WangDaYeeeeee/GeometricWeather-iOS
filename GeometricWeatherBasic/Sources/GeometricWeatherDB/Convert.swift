//
//  Convert.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources

func injectLocationEntity(
    entity: LocationEntity,
    location: Location,
    createTime: Double = Date().timeIntervalSince1970
) {
    
    entity.formattedId = location.formattedId
    entity.createTime = createTime
    
    entity.cityId = location.cityId
    
    entity.latitude = location.latitude
    entity.longitude = location.longitude
    entity.timezone = location.timezone.identifier
    
    entity.country = location.country
    entity.province = location.province
    entity.city = location.city
    entity.district = location.district
    
    entity.weatherSource = location.weatherSource.key
    
    entity.currentPosition = location.currentPosition
    entity.residentPosition = location.residentPosition
}

func generateLocation(
    entity: LocationEntity
) -> Location {
    
    return Location(
        cityId: entity.cityId ?? "111",
        latitude: entity.latitude,
        longitude: entity.longitude,
        timezone: TimeZone(identifier: entity.timezone ?? "shanghai") ?? TimeZone.current,
        country: entity.country ?? "",
        province: entity.province ?? "",
        city: entity.city ?? "",
        district: entity.district ?? "",
        weather: nil,
        weatherSource: WeatherSource[entity.weatherSource ?? ""],
        currentPosition: entity.currentPosition,
        residentPosition: entity.residentPosition
    )
}

func injectWeatherEntity(
    entity: WeatherEntity,
    weather: Weather,
    formatted: String
) {
    entity.formattedId = formatted
    do {
        entity.json = String(
            data: try JSONEncoder().encode(weather),
            encoding: .utf8
        )
    } catch {
        printLog(keyword: "db", content: "Error when encoding weather to json: \(error)")
        entity.json = ""
    }
}

func generateWeather(
    entity: WeatherEntity
) -> Weather? {
    do {
        return try JSONDecoder().decode(
            Weather.self,
            from: entity.json?.data(
                using: .utf8,
                allowLossyConversion: true
            ) ?? Data()
        )
    } catch {
        printLog(keyword: "db", content: "Error when decoding json to weather: \(error)")
        return nil
    }
}
