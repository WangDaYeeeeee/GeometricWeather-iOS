//
//  AppExtensionHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/10.
//

import Foundation
import WidgetKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

// MARK: - response.

struct AppShortcutItemAction {
    
    let formattedId: String
}

func responseAppShortcutItemAction(
    _ shortcutItem: UIApplicationShortcutItem
) {
    EventBus.shared.post(
        AppShortcutItemAction(formattedId: shortcutItem.type)
    )
}

// MARK: - update.

func updateAppExtensions() {
    // app widgets.
    WidgetCenter.shared.reloadAllTimelines()
    
    Task(priority: .background) {
        // app shortcut items.
        await updateAppShortcutItems()
        
        // watch app.
        var location = await DatabaseHelper.shared.asyncReadLocations()[0]
        location = location.copyOf(
            weather: await DatabaseHelper.shared.asyncReadWeather(
                formattedId: location.formattedId
            )
        )
        await WatchConnectionHelper.shared.shareLocationUpdateResult(location: location)
    }
}

private func updateAppShortcutItems() async {
    let items = Location.excludeInvalidResidentLocation(
        locationArray: await DatabaseHelper.shared.asyncReadLocations()
    ).map { location in
        UIApplicationShortcutItem(
            type: location.formattedId,
            localizedTitle: getLocationText(location: location),
            localizedSubtitle: location.toString(),
            icon: UIApplicationShortcutIcon(
                type: location.currentPosition
                ? .location
                : .markLocation
            ),
            userInfo: nil
        )
    }
    
    await MainActor.run {
        UIApplication.shared.shortcutItems = items
    }
}
