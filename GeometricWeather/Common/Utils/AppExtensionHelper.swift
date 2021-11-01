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
    updateAppShortcutItems()
}

private func updateAppShortcutItems() {
    DispatchQueue.global(qos: .background).async {
        var locations = DatabaseHelper.shared.readLocations()
        locations = Location.excludeInvalidResidentLocation(locationArray: locations)
        
        DispatchQueue.main.async {
            var items = [UIApplicationShortcutItem]()
            
            for location in locations {
                let item = UIApplicationShortcutItem(
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
                items.append(item)
            }
            
            UIApplication.shared.shortcutItems = items
        }
    }
}
