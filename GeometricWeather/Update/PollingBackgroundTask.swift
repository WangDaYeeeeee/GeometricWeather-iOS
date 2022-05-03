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
        Task.detached(priority: .userInitiated) {
            await polling(onTask: task)
        }
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

private func polling(onTask task: BGTask) async {
    printLog(keyword: "polling", content: "schedule again")
    schedulePollingBackgroundTask()
    
    printLog(keyword: "polling", content: "register expiration handler")
    task.expirationHandler = {
        printLog(keyword: "polling", content: "expiration")
        updateAppExtensionsAndPrintLog()
    }
    
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
    
    let succeed = await withTaskGroup(of: _PollingResult.self) { group -> Bool in
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
            succeed = succeed
            && result.inner.locationSucceed == true
            && result.inner.weatherRequestSucceed
        }
        
        return succeed
    }
    
    updateAppExtensionsAndPrintLog()
    
    printLog(keyword: "polling", content: "polling complete with result: \(succeed)")
    task.setTaskCompleted(success: succeed)
}

private func updateAppExtensionsAndPrintLog() {
    printLog(keyword: "widget", content: "update app extensions cause polling updated")
    updateAppExtensions()
}
