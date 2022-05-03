//
//  AppExtensionHelper.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/10.
//

import Foundation
import WidgetKit
import GeometricWeatherBasic

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
    
    // app shortcut items.
    updateAppShortcutItemsInTask()
}

private func updateAppShortcutItemsInTask() {
    Task.detached(priority: .background) {
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
        
        await updateAppShortcutItems(items)
    }
}

@MainActor
private func updateAppShortcutItems(_ items: [UIApplicationShortcutItem]) {
    UIApplication.shared.shortcutItems = items
}
