//
//  DAOs.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation
import CoreData

class DAOs {
    
    // MARK: - location.
    
    static func readLocations(
        context: NSManagedObjectContext
    ) -> [Location] {
        var locations = [Location]()
        
        do {
            let fetchRequest = NSFetchRequest<LocationEntity>(
                entityName: "LocationEntity"
            )
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "createTime", ascending: true)
            ]
            
            let fetchedObjects = try context.fetch(fetchRequest)
            for object in fetchedObjects {
                locations.append(
                    generateLocation(entity: object)
                )
                printLog(
                    keyword: "db",
                    content: "read location: \(locations.last?.formattedId ?? "nil instance")"
                )
            }
        } catch {
            fatalError("read all locations failed：\(error)")
        }
        
        printLog(
            keyword: "db",
            content: "read location count = \(locations.count)"
        )
        return locations
    }

    static func readLocations(
        context: NSManagedObjectContext,
        formattedId: String
    ) -> [Location] {
        var locations = [Location]()
        
        let fetchRequest = NSFetchRequest<LocationEntity>(
            entityName: "LocationEntity"
        )
        fetchRequest.predicate = NSPredicate(
            format: "formattedId = '\(formattedId)' ",
            ""
        )
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            for object in fetchedObjects {
                locations.append(
                    generateLocation(entity: object)
                )
                printLog(
                    keyword: "db",
                    content: "read location: \(locations.last?.formattedId ?? "nil instance")")
            }
        } catch {
            fatalError("read all locations failed：\(error)")
        }
        
        printLog(
            keyword: "db",
            content: "read location count = \(locations.count)"
        )
        return locations
    }

    static func writeLocation(
        context: NSManagedObjectContext,
        location: Location
    ) {
        let entity = NSEntityDescription.insertNewObject(
            forEntityName: "LocationEntity",
            into: context
        ) as! LocationEntity

        injectLocationEntity(entity: entity, location: location)
        
        do {
            try context.save()
            printLog(
                keyword: "db",
                content: "insert location: \(location.formattedId)"
            )
        } catch {
            fatalError("insert location failed：\(error)")
        }
    }

    static func writeLocations(
        context: NSManagedObjectContext,
        locations: [Location]
    ) {
        for location in locations {
            let entity = NSEntityDescription.insertNewObject(
                forEntityName: "LocationEntity",
                into: context
            ) as! LocationEntity

            injectLocationEntity(entity: entity, location: location)
        }
        
        do {
            try context.save()
            printLog(
                keyword: "db",
                content: "insert locations: * \(locations.count)"
            )
        } catch {
            fatalError("insert locations failed：\(error)")
        }
    }

    static func deleteLocation(
        context: NSManagedObjectContext,
        formattedId: String
    ) {
        let fetchRequest = NSFetchRequest<LocationEntity>(
            entityName: "LocationEntity"
        )
        fetchRequest.predicate = NSPredicate(
            format: "formattedId = '\(formattedId)' ",
            ""
        )

        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            for object in fetchedObjects{
                context.delete(object)
                printLog(keyword: "db", content: "delete location: \(formattedId)")
            }
            try context.save()
        } catch {
            fatalError("delete location failed：\(error)")
        }
    }

    static func deleteLocations(
        context: NSManagedObjectContext
    ) {
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: NSFetchRequest<NSFetchRequestResult>(
                entityName: "LocationEntity"
            )
        )
        do {
            try context.execute(deleteRequest)
            try context.save()
            printLog(keyword: "db", content: "delete all locations")
        } catch {
            fatalError("delete all locations failed：\(error)")
        }
    }

    static func updateLocation(
        context: NSManagedObjectContext,
        location: Location
    ) {
        let fetchRequest = NSFetchRequest<LocationEntity>(
            entityName: "LocationEntity"
        )
        fetchRequest.predicate = NSPredicate(
            format: "formattedId = '\(location.formattedId)' ",
            ""
        )

        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            for object in fetchedObjects{
                injectLocationEntity(
                    entity: object,
                    location: location,
                    createTime: object.createTime
                )
            }
            
            try context.save()
            printLog(
                keyword: "db",
                content: "update location: \(location.formattedId)"
            )
        } catch {
            fatalError("delete location failed：\(error)")
        }
    }

    // MARK: - weather.

    static func readWeather(
        context: NSManagedObjectContext,
        formattedId: String
    ) -> Weather? {
        var weather: Weather? = nil
        
        let fetchRequest = NSFetchRequest<WeatherEntity>(
            entityName: "WeatherEntity"
        )
        fetchRequest.predicate = NSPredicate(
            format: "formattedId = '\(formattedId)' ",
            ""
        )
        
        do {
            let fetchedObjects = try context.fetch(
                fetchRequest
            )
            for object in fetchedObjects {
                weather = generateWeather(entity: object)
                printLog(
                    keyword: "db",
                    content: "read weather: \(formattedId)"
                )
                if weather != nil {
                    break
                }
            }
        } catch {
            fatalError("read weather failed：\(error)")
        }
        
        return weather
    }

    static func writeWeather(
        context: NSManagedObjectContext,
        weather: Weather,
        formattedId: String
    ) {
        let entity = NSEntityDescription.insertNewObject(
            forEntityName: "WeatherEntity",
            into: context
        ) as! WeatherEntity

        injectWeatherEntity(
            entity: entity,
            weather: weather,
            formatted: formattedId
        )
        
        do {
            try context.save()
            printLog(
                keyword: "db",
                content: "insert weather: \(formattedId)"
            )
        } catch {
            fatalError("insert weather failed：\(error)")
        }
    }

    static func deleteWeather(
        context: NSManagedObjectContext,
        formattedId: String
    ) {
        let fetchRequest = NSFetchRequest<WeatherEntity>(
            entityName: "WeatherEntity"
        )
        fetchRequest.predicate = NSPredicate(
            format: "formattedId = '\(formattedId)' ",
            ""
        )

        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            for object in fetchedObjects{
                context.delete(object)
                printLog(
                    keyword: "db",
                    content: "delete weather: \(formattedId)"
                )
            }
            try context.save()
        } catch {
            fatalError("delete weather failed：\(error)")
        }
    }

    static func deleteWeathers(
        context: NSManagedObjectContext
    ) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
            entityName: "LocationEntity"
        )
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )
        do {
            try context.execute(deleteRequest)
            try context.save()
            printLog(keyword: "db", content: "delete all locations")
        } catch {
            fatalError("delete all locations failed：\(error)")
        }
    }
}
