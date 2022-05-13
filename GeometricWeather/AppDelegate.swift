//
//  AppDelegate.swift
//  Demo
//
//  Created by 王大爷 on 2021/8/1.
//

import UIKit
import CoreData
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherDB
import GeometricWeatherTheme

@main
class AppDelegate: UIResponder,
                    UIApplicationDelegate,
                    UNUserNotificationCenterDelegate {
        
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // register needle for di.
        registerProviderFactories()
        
        // request notification authorization and set delegate.
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in
            // do nothing.
        }
        UNUserNotificationCenter.current().delegate = self
        
        // register background fetch task.
        registerPollingBackgroundTask()

        EventBus.shared.register(self, for: UpdateIntervalChanged.self) { event in
            registerPollingBackgroundTask()
        }
        
        // register forecast pending notifications.
        Task(priority: .background) {
            if let weather = await DatabaseHelper.shared.asyncReadWeather(
                formattedId: await DatabaseHelper.shared.asyncReadLocations()[0].formattedId
            ) {
                resetTodayForecastPendingNotification(weather: weather)
                resetTomorrowForecastPendingNotification(weather: weather)
            }
        }
        
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - restoration.
    
    func application(
        _ application: UIApplication,
        shouldSaveSecureApplicationState coder: NSCoder
    ) -> Bool {
        return true
    }
    
    func application(
        _ application: UIApplication,
        shouldRestoreSecureApplicationState coder: NSCoder
    ) -> Bool {
        return true
    }
    
    // MARK: - UNUserNotification Delegate.
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        responseNotificationAction(response)
        completionHandler()
    }
}

