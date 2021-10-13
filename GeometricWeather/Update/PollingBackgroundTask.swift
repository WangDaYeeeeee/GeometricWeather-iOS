//
//  PollingBackgroundProcess.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/3.
//

import Foundation
import BackgroundTasks
import GeometricWeatherBasic
import SwiftUI

let pollingIntervalInHours = 1.0

private let identifier = "com.wangdaye.geometricweather.polling"

// MARK: - notification.

extension Notification.Name {
    
    // send notification with a location object.
    static let backgroundUpdate = NSNotification.Name(
        "com.wangdaye.geometricweather.backgroundUpdate"
    )
}

// MARK: - polling task.

func registerPollingBackgroundTask() {
    BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
    
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: identifier,
        using: .main
    ) { task in
        polling(onTask: task)
    }
    
    schedulePollingBackgroundTask()
}

func schedulePollingBackgroundTask() {
    do {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(
            timeIntervalSinceNow: pollingIntervalInHours * 60 * 60
        )
        try BGTaskScheduler.shared.submit(request)
        printLog(
            keyword: "polling",
            content: "submit polling task"
        )
    } catch {
        printLog(
            keyword: "polling",
            content: "Could not submit polling task cause: \(error)"
        )
    }
}

private func polling(onTask task: BGTask) {
    printLog(keyword: "polling", content: "schedule again")
    schedulePollingBackgroundTask()
    
    printLog(keyword: "polling", content: "prepare")
    var tokenDict = [String: UpdateHelper]()
    task.expirationHandler = {
        printLog(keyword: "polling", content: "expiration")
        for updateHelper in tokenDict.values {
            updateHelper.cancel()
        }
        tokenDict.removeAll()
        
        updateAppExtensionsAndPrintLog()
    }
    
    var progress = 0
    var suceed = true
    
    printLog(keyword: "polling", content: "read locations")
    readLocations { locations in
        for location in locations {
            let updateHelper = UpdateHelper()
            tokenDict[location.formattedId] = updateHelper
            
            printLog(keyword: "polling", content: "polling at: \(location.formattedId)")
            updateHelper.update(
                target: location,
                inBackground: true
            ) { location, locationSucceed, requestWeatherSucceed in
                printLog(keyword: "polling", content: "polling at: \(location.formattedId) result")
                progress += 1
                tokenDict.removeValue(forKey: location.formattedId)
                
                if let weather = location.weather {
                    if location.formattedId == locations[0].formattedId {
                        // default location.
                        checkToPushAlertNotification(
                            newWeather: weather,
                            oldWeahter: locations[0].weather
                        )
                        checkToPushPrecipitationNotification(weather: weather)
                        
                        resetTodayForecastPendingNotification(weather: weather)
                        resetTomorrowForecastPendingNotification(weather: weather)
                    }
                    
                    printLog(keyword: "polling", content: "polling to save: \(location.formattedId)")
                    DispatchQueue.global(qos: .background).async {
                        DatabaseHelper.shared.writeWeather(
                            weather: weather,
                            formattedId: location.formattedId
                        )
                    }
                    
                    printLog(keyword: "polling", content: "polling to post: \(location.formattedId)")
                    NotificationCenter.default.post(
                        name: .backgroundUpdate,
                        object: location
                    )
                } else {
                    suceed = false
                }
                
                if progress == locations.count {
                    updateAppExtensionsAndPrintLog()
                    
                    printLog(keyword: "polling", content: "polling complete with result: \(suceed)")
                    task.setTaskCompleted(success: suceed)
                }
            }
        }
    }
}

private func readLocations(
    withCallback callback: @escaping (_ locations: [Location]) -> Void
) {
    DispatchQueue.global(qos: .background).async {
        var locations = DatabaseHelper.shared.readLocations()
        
        locations[0] = locations[0].copyOf(
            weather: DatabaseHelper.shared.readWeather(
                formattedId: locations[0].formattedId
            )
        )
        
        DispatchQueue.main.async {
            callback(locations)
        }
    }
}

private func updateAppExtensionsAndPrintLog() {
    printLog(keyword: "widget", content: "update app extensions cause polling updated")
    updateAppExtensions()
}
