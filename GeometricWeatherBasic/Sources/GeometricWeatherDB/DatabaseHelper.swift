//
//  DatabaseHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import Foundation
import CoreData
import GeometricWeatherCore
import GeometricWeatherResources

extension URL {

    static let storeURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: "group.wangdaye.com.GeometricWeather"
    )!.appendingPathComponent(
        "GeometricWeather.sqlite"
    )
}

// MARK: - helper.

public class DatabaseHelper {
    
    // singleton.
    
    public static let shared = DatabaseHelper()

    private init() {
        // do nothing.
    }
    
    // proterties.
    
    private lazy var persistentContainer: NSPersistentContainer? = {
        
        guard let modelURL = Bundle.shared.url(
            forResource:"GeometricWeather",
            withExtension: "momd"
        ) else {
            return nil
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            return nil
        }
        let container = NSPersistentContainer(
            name: "GeometricWeather",
            managedObjectModel: model
        )
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: .storeURL)
        ]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                printLog(
                    keyword: "db",
                    content: "Unresolved error when create a persistent container: \(error), \(error.userInfo)"
                )
            }
        })
        return container
    }()
    
    // interfaces.
    
    // location.
    
    public func suspendedWriteLocation(location: Location) async {
        await withCheckedContinuation { continuation in
            continuation.resume(returning: self.writeLocation(location: location))
        }
    }
    public func writeLocation(location: Location) {
        if let context = self.persistentContainer?.viewContext {
            context.performAndWait {
                if DAOs.readLocations(
                    context: context,
                    formattedId: location.formattedId
                ).isEmpty {
                    DAOs.writeLocation(context: context, location: location)
                } else {
                    DAOs.updateLocation(context: context, location: location)
                }
                try? context.save()
            }
        }
    }
    
    public func suspendedWriteLocations(locations: [Location]) async {
        await withCheckedContinuation { continuation in
            continuation.resume(returning: self.writeLocations(locations: locations))
        }
    }
    public func writeLocations(locations: [Location]) {
        if let context = self.persistentContainer?.viewContext {
            context.performAndWait {
                DAOs.deleteLocations(context: context)
                DAOs.writeLocations(context: context, locations: locations)
                try? context.save()
            }
        }
    }
    
    public func suspendedDeleteLocation(formattedId: String) async {
        await withCheckedContinuation { continuation in
            continuation.resume(returning: self.deleteLocation(formattedId: formattedId))
        }
    }
    public func deleteLocation(formattedId: String) {
        if let context = self.persistentContainer?.viewContext {
            DAOs.deleteLocation(context: context, formattedId: formattedId)
            try? context.save()
        }
    }
    
    public func suspendedReadLocation(formattedId: String) async -> Location? {
        await withCheckedContinuation { continuation in
            continuation.resume(returning: self.readLocation(formattedId: formattedId))
        }
    }
    public func readLocation(formattedId: String) -> Location? {
        if let context = self.persistentContainer?.viewContext {
            return DAOs.readLocations(
                context: context,
                formattedId: formattedId
            ).first
        }
        return nil
    }
    
    public func suspendedReadLocations(defualtWeatherSource: WeatherSource) async -> [Location] {
        await withCheckedContinuation { continuation in
            continuation.resume(
                returning: readLocations(defualtWeatherSource: defualtWeatherSource)
            )
        }
    }
    public func readLocations(defualtWeatherSource: WeatherSource) -> [Location] {
        var locations = [Location]()
        
        if let context = self.persistentContainer?.viewContext {
            context.performAndWait {
                locations = DAOs.readLocations(context: context)
                
                if locations.isEmpty {
                    locations.append(
                        Location.buildLocal(weatherSource: defualtWeatherSource)
                    )
                    DAOs.writeLocations(context: context, locations: locations)
                }
            }
        }
        
        return locations
    }
    
    // weather.
    
    public func suspendedWriteWeather(
        weather: Weather,
        formattedId: String
    ) async {
        await withCheckedContinuation { continuation in
            continuation.resume(
                returning: self.writeWeather(weather: weather, formattedId: formattedId)
            )
        }
    }
    public func writeWeather(
        weather: Weather,
        formattedId: String
    ) {
        if let context = self.persistentContainer?.viewContext {
            context.performAndWait {
                DAOs.deleteWeather(
                    context: context,
                    formattedId: formattedId
                )
                DAOs.writeWeather(
                    context: context,
                    weather: weather,
                    formattedId: formattedId
                )
                try? context.save()
            }
        }
    }
    
    public func suspendedDeleteWeather(formattedId: String) async {
        await withCheckedContinuation { continuation in
            continuation.resume(returning: self.deleteWeather(formattedId: formattedId))
        }
    }
    public func deleteWeather(formattedId: String) {
        if let context = self.persistentContainer?.viewContext {
            DAOs.deleteWeather(context: context, formattedId: formattedId)
            try? context.save()
        }
    }
    
    public func suspendedReadWeather(formattedId: String) async -> Weather? {
        await withCheckedContinuation { continuation in
            continuation.resume(returning: self.readWeather(formattedId: formattedId))
        }
    }
    public func readWeather(formattedId: String) -> Weather? {
        if let context = self.persistentContainer?.viewContext {
            return DAOs.readWeather(context: context, formattedId: formattedId)
        }
        return nil
    }
    
    // check to save.
    
    public func checkToSaveContext () {
        if let context = self.persistentContainer?.viewContext {
            if !context.hasChanges {
                return
            }
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
