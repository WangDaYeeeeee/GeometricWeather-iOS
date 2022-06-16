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

struct LocationListUpdateEvent {
    let locations: [Location]
    weak var scene: UIWindowScene?
}

func updateAppExtensions(
    locations: [Location]?,
    scene: UIWindowScene? = nil
) {
    // app widgets.
    WidgetCenter.shared.reloadAllTimelines()
    
    if let locations = locations {
        // app shortcut items.
        updateAppShortcutItems(locations: locations)
        
        // multi-scene compat.
        EventBus.shared.post(
            LocationListUpdateEvent(locations: locations, scene: scene)
        )
    }
    
    // watch app.
    Task(priority: .background) {
        if let locations = locations {
            await WatchConnectionHelper.shared.shareLocationUpdateResult(locations: locations)
        }
    }
}

private func updateAppShortcutItems(locations: [Location]) {
    UIApplication.shared.shortcutItems = Location.excludeInvalidResidentLocation(
        locationArray: locations
    ).map { location in
        UIApplicationShortcutItem(
            type: location.formattedId,
            localizedTitle: getLocationText(location: location),
            localizedSubtitle: location.toString(),
            icon: UIApplicationShortcutIcon(
                systemImageName: SFResourceProvider.shared.getWeatherIconName(
                    weatherCode: location.weather?.current.weatherCode ?? .clear,
                    daylight: location.isDaylight
                )
            ),
            userInfo: nil
        )
    }
}
