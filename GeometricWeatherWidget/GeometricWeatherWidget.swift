//
//  GeometricWeatherWidget.swift
//  GeometricWeatherWidget
//
//  Created by 王大爷 on 2021/9/23.
//

import WidgetKit
import SwiftUI
import Intents
import GeometricWeatherBasic

func readLocationWithWeatherCache() -> Location {
    
    let location = DatabaseHelper.shared.readLocations().first
    ?? Location.buildDefaultLocation(
        weatherSource: WeatherSource[0],
        residentPosition: false
    )
    
    return location.copyOf(
        weather: DatabaseHelper.shared.readWeather(
            formattedId: location.formattedId
        )
    )
}

// MARK: - provider.

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> GeoWidgetEntry {
        GeoWidgetEntry(
            location: readLocationWithWeatherCache(),
            date: Date(),
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (GeoWidgetEntry) -> ()
    ) {
        completion(
            GeoWidgetEntry(
                location: readLocationWithWeatherCache(),
                date: Date(),
                configuration: ConfigurationIntent()
            )
        )
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<GeoWidgetEntry>) -> ()
    ) {
        completion(
            Timeline(entries: [
                GeoWidgetEntry(
                    location: readLocationWithWeatherCache(),
                    date: Date().addingTimeInterval(30 * 60),
                    configuration: ConfigurationIntent()
                )
            ], policy: .atEnd)
        )
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
    }
}