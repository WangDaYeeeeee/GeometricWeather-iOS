//
//  MainRepository.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/25.
//

import Foundation
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme
import GeometricWeatherUpdate

struct MainRepository {
    
    private let updator = UpdateHelper()
    
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
        ignoredFormattedId: Set<String>
    ) async -> [Location] {
        var locations = oldList
                
        for i in locations.indices {
            if ignoredFormattedId.contains(locations[i].formattedId) {
                continue
            }
            
            locations[i] = locations[i].copyOf(
                weather: await DatabaseHelper.shared.asyncReadWeather(
                    formattedId: locations[i].formattedId
                )
            )
        }
        
        return locations
    }
    
    func readWeatherCache(for location: Location) -> Location {
        return location.copyOf(
            weather: DatabaseHelper.shared.readWeather(formattedId: location.formattedId)
        )
    }
    
    func writeLocations(locations: [Location]) async {
        await DatabaseHelper.shared.asyncWriteLocations(locations: locations)
    }

    func writeLocations(
        locations: [Location],
        index: Int? = nil
    ) async {
        await writeLocations(locations: locations)
        
        if let i = index {
            if let weather = locations[i].weather {
                await DatabaseHelper.shared.asyncWriteWeather(
                    weather: weather,
                    formattedId: locations[i].formattedId
                )
            }
        }
    }
    
    func deleteLocation(location: Location) async {
        await DatabaseHelper.shared.asyncDeleteLocation(formattedId: location.formattedId)
        await DatabaseHelper.shared.asyncDeleteWeather(formattedId: location.formattedId)
    }
    
    func update(location: Location) async -> UpdateResult {
        return await updator.update(target: location, inBackground: false)
    }
}
