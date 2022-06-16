//
//  PollingBackgroundProcess.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/9/3.
//

import Foundation
import BackgroundTasks
import GeometricWeatherCore
import GeometricWeatherDB
import GeometricWeatherSettings
import GeometricWeatherUpdate
import SwiftUI

private let identifier = "com.wangdaye.geometricweather.polling"

private struct _PollingResult {
    let inner: UpdateResult
    let index: Int
}

// MARK: - event.

struct BackgroundUpdateEvent {
    let location: Location
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
            timeIntervalSinceNow: SettingsManager.shared.updateInterval.hours * 60 * 60
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
    
    let asyncTask = Task(priority: .high) {
        let (locations, succeed) = await polling()
        
        printLog(keyword: "polling", content: "polling complete with result: \(succeed)")
        updateAppExtensionsAndPrintLog(locations: locations)
        
        task.setTaskCompleted(success: succeed)
    }
    
    printLog(keyword: "polling", content: "register expiration handler")
    task.expirationHandler = {
        printLog(keyword: "polling", content: "expiration handler executing")
        updateAppExtensions(locations: nil)
        asyncTask.cancel()
    }
}

private func polling() async -> (locations: [Location], succeed: Bool) {
    printLog(keyword: "polling", content: "read locations")
    // read weather cache for default weather for alert comparison.
    var locations = await DatabaseHelper.shared.asyncReadLocations()
    locations[0] = locations[0].copyOf(
        weather: await DatabaseHelper.shared.asyncReadWeather(
            formattedId: locations[0].formattedId
        )
    )
    
    let helpers = locations.map { _ in
        UpdateHelper()
    }
    
    return await withTaskGroup(of: _PollingResult.self) { group -> ([Location], Bool) in
        var locations = locations
        var succeed = true
        
        for (index, location) in locations.enumerated() {
            group.addTask(
                priority: location.formattedId == locations[0].formattedId
                ? .high
                : .medium
            ) {
                return _PollingResult(
                    inner: await helpers[index].update(target: location, inBackground: true),
                    index: index
                )
            }
        }
        for await result in group {
            locations[result.index] = result.inner.location
            succeed = succeed
            && result.inner.locationSucceed != false
            && result.inner.weatherRequestSucceed
        }
        
        return (locations, succeed)
    }
}

private func updateAppExtensionsAndPrintLog(locations: [Location]?) {
    printLog(keyword: "widget", content: "update app extensions cause polling updated")
    updateAppExtensions(locations: locations, scene: nil)
}
