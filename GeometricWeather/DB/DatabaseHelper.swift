//
//  DatabaseHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation
import CoreData
import UIKit

// MARK: - helper.

class DatabaseHelper {
    
    // singleton.
    
    static let shared = DatabaseHelper()

    private init() {
        self.context = (
            UIApplication.shared.delegate as! AppDelegate
        ).persistentContainer.viewContext
    }
    
    // proterties.
        
    private weak var context: NSManagedObjectContext?
    
    // interfaces.
    
    // location.
    
    func writeLocation(location: Location) {
        if let context = self.context {
            context.performAndWait {
                if GeometricWeather.readLocations(
                    context: context,
                    formattedId: location.formattedId
                ).isEmpty {
                    GeometricWeather.writeLocation(context: context, location: location)
                } else {
                    GeometricWeather.updateLocation(context: context, location: location)
                }
            }
        }
    }
    
    func writeLocations(locations: [Location]) {
        if let context = self.context {
            context.performAndWait {
                GeometricWeather.deleteLocations(context: context)
                GeometricWeather.writeLocations(context: context, locations: locations)
            }
        }
    }
    
    func deleteLocation(formattedId: String) {
        if let context = self.context {
            GeometricWeather.deleteLocation(context: context, formattedId: formattedId)
        }
    }
    
    func readLocation(formattedId: String) -> Location? {
        if let context = self.context {
            let locations = GeometricWeather.readLocations(context: context, formattedId: formattedId)
            return locations.isEmpty ? nil : locations[0]
        }
        return nil
    }
    
    func readLocations() -> [Location] {
        var locations = [Location]()
        
        if let context = self.context {
            context.performAndWait {
                locations = GeometricWeather.readLocations(context: context)
                
                if locations.isEmpty {
                    locations.append(Location.buildLocal())
                    GeometricWeather.writeLocations(context: context, locations: locations)
                }
            }
        }
        
        return locations
    }
    
    // weather.
    
    func writeWeather(
        weather: Weather,
        formattedId: String
    ) {
        if let context = self.context {
            context.performAndWait {
                GeometricWeather.deleteWeather(context: context, formattedId: formattedId)
                GeometricWeather.writeWeather(context: context, weather: weather, formattedId: formattedId)
            }
        }
    }
    
    func deleteWeather(formattedId: String) {
        if let context = self.context {
            GeometricWeather.deleteWeather(context: context, formattedId: formattedId)
        }
    }
    
    func readWeather(formattedId: String) -> Weather? {
        if let context = self.context {
            return GeometricWeather.readWeather(context: context, formattedId: formattedId)
        }
        return nil
    }
}
