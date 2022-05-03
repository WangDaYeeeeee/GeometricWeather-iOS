//
//  GeometricWeatherApp.swift
//  GeometricWeatherWatch WatchKit Extension
//
//  Created by 王大爷 on 2022/5/2.
//

import SwiftUI

@main
struct GeometricWeatherApp: App {
    
    @SceneBuilder
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView()
            }
        }

        WKNotificationScene(
            controller: NotificationController.self,
            category: "myCategory"
        )
    }
}
