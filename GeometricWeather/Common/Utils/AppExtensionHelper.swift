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

extension Notification.Name {
    
    // send notification with formatted id of location.
    static let appShortcutItemAction = NSNotification.Name(
        "com.wangdaye.geometricweather.appShortcutItemAction"
    )
}

func responseAppShortcutItemAction(
    _ shortcutItem: UIApplicationShortcutItem
) {
    DispatchQueue.main.async {
        NotificationCenter.default.postToMainThread(
            name: .appShortcutItemAction,
            object: shortcutItem.type
        )
    }
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
