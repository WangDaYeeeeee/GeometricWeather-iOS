//
//  MainRepository.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/25.
//

import Foundation
import GeometricWeatherBasic

class MainRepository {
    
    private let updator = UpdateHelper()
    private let dbQueue = DispatchQueue(
        label: "main_dbDispatchQueue",
        qos: .background,
        attributes: .concurrent,
        autoreleaseFrequency: .inherit
    )
    
    // return total locations and valid locations.
    func initLocations() -> (
        total: [Location],
        valid: [Location]
    ) {
        
        var totalLocaitons = DatabaseHelper.shared.readLocations()
        var validLocations = Location.excludeInvalidResidentLocation(
            locationArray: totalLocaitons
        )
        
        // read weather cache from db for first location.
        let weather = DatabaseHelper.shared.readWeather(
            formattedId: validLocations[0].formattedId
        )
        validLocations[0] = validLocations[0].copyOf(
            weather: weather
        )
        for i in 0 ..< totalLocaitons.count {
            if totalLocaitons[i].formattedId == validLocations[0].formattedId {
                totalLocaitons[i] = totalLocaitons[0].copyOf(
                    weather: weather
                )
                break
            }
        }
        
        return (totalLocaitons, validLocations)
    }
    
    func getWeatherCacheForLocations(
        oldList: [Location],
        ignoredFormattedId: String,
        callback: @escaping ([Location]) -> Void
    ) {
        dbQueue.async {
            var locations = oldList
                    
            for i in locations.indices {
                if locations[i].formattedId == ignoredFormattedId {
                    continue
                }
                
                locations[i] = locations[i].copyOf(
                    weather: DatabaseHelper.shared.readWeather(
                        formattedId: locations[i].formattedId
                    )
                )
            }
            
            DispatchQueue.main.async {
                callback(locations)
            }
        }
    }
    
    func writeLocations(locations: [Location]) {
        dbQueue.async {
            DatabaseHelper.shared.writeLocations(locations: locations)
        }
    }

    func writeLocations(
        locations: [Location],
        index: Int? = nil
    ) {
        writeLocations(locations: locations)
        
        if let i = index {
            if let weather = locations[i].weather {
                dbQueue.async {
                    DatabaseHelper.shared.writeWeather(
                        weather: weather,
                        formattedId: locations[i].formattedId
                    )
                }
            }
        }
    }
    
    func deleteLocation(location: Location) {
        dbQueue.async {
            DatabaseHelper.shared.deleteLocation(formattedId: location.formattedId)
            DatabaseHelper.shared.deleteWeather(formattedId: location.formattedId)
        }
    }
    
    func update(
        location: Location,
        // location, location result, weather request result.
        callback: @escaping (Location, Bool?, Bool) -> Void
    ) {
        updator.update(
            target: location,
            inBackground: false,
            callback: callback
        )
    }
    
    func cancel() {
        updator.cancel()
    }
}
