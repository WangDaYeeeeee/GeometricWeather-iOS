//
//  GeometricWeatherWidget.swift
//  GeometricWeatherWidget
//
//  Created by 王大爷 on 2021/9/23.
//

import WidgetKit
import SwiftUI
import Intents
import GeometricWeatherCore
import GeometricWeatherSettings
import GeometricWeatherDB

func readLocationWithWeatherCache() async -> Location {
    let location = await DatabaseHelper.shared.asyncReadLocations().first
    ?? Location.buildDefaultLocation(
        weatherSource: WeatherSource[0],
        residentPosition: false
    )
    
    return location.copyOf(
        weather: await DatabaseHelper.shared.asyncReadWeather(
            formattedId: location.formattedId
        )
    )
}

// MARK: - provider.

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> GeoWidgetEntry {
        GeoWidgetEntry(
            location: Location.buildDefaultLocation(
                weatherSource: WeatherSource[0],
                residentPosition: false
            ),
            date: Date(),
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (GeoWidgetEntry) -> ()
    ) {
        Task(priority: .userInitiated) {
            let location = await readLocationWithWeatherCache()
            
            await MainActor.run {
                completion(
                    GeoWidgetEntry(
                        location: location,
                        date: Date(),
                        configuration: ConfigurationIntent()
                    )
                )
            }
        }
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<GeoWidgetEntry>) -> ()
    ) {
        Task(priority: .userInitiated) {
            let location = await readLocationWithWeatherCache()
            let timeline = Timeline(
                entries: [
                    GeoWidgetEntry(
                        location: location,
                        date: Date(),
                        configuration: ConfigurationIntent()
                    )
                ],
                policy: .after(Date().addingTimeInterval(15 * 60))
            )
            await MainActor.run {
                completion(timeline)
            }
        }
    }
}

// MARK: - entry.

struct GeoWidgetEntry: TimelineEntry {
    let location: Location
    let date: Date
    let configuration: ConfigurationIntent
    let settings = SettingsManager.shared
}

// MARK: - widget bundle.

@main
struct GeometricWeatherWidget: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        WeatherWidget()
        DailyWidget()
        DailyWidget2()
        AQIWidget()
        CurrentWidget()
    }
}
