//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by 王大爷 on 2021/9/17.
//

import WidgetKit
import SwiftUI
import Intents
import GeometricWeatherBasic

private func readLocationWithWeatherCache() -> Location {
    
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
    
    func placeholder(in context: Context) -> WeatherWidgetEntry {
        WeatherWidgetEntry(
            location: readLocationWithWeatherCache(),
            date: Date(),
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (WeatherWidgetEntry) -> ()
    ) {
        completion(
            WeatherWidgetEntry(
                location: readLocationWithWeatherCache(),
                date: Date(),
                configuration: ConfigurationIntent()
            )
        )
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        completion(
            Timeline(entries: [
                WeatherWidgetEntry(
                    location: readLocationWithWeatherCache(),
                    date: Date(),
                    configuration: ConfigurationIntent()
                )
            ], policy: .never)
        )
    }
}

// MARK: - entry.

struct WeatherWidgetEntry: TimelineEntry {
    let location: Location
    let date: Date
    let configuration: ConfigurationIntent
    let settings = SettingsManager.shared
}

// MARK: - view.

struct WeatherWidgetEntryView : View {
    
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            ThemeManager.shared.weatherThemeDelegate.getWidgetBackground(
                weatherKind: weatherCodeToWeatherKind(
                    code: self.entry.location.weather?.current.weatherCode ?? .clear
                ),
                daylight: self.entry.location.daylight
            )
            
            switch self.family {
            case .systemSmall:
                WeatherWidgetSmallView(location: self.entry.location)
            case .systemMedium:
                WeatherWidgetMediumView(location: self.entry.location)
            default:
                WeatherWidgetLargeView(location: self.entry.location)
            }
        }
    }
}

// MARK: - widget.

@main
struct WeatherWidget: Widget {
    
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            WeatherWidgetEntryView(entry: entry)
        }.configurationDisplayName(
            "Forecast"
        ).description(
            "Get forecast for a selected location."
        )
    }
}

// MARK: - preview.

struct WeatherWidget_Previews: PreviewProvider {
        
    static var previews: some View {
        let entry = WeatherWidgetEntry(
            location: readLocationWithWeatherCache(),
            date: Date(),
            configuration: ConfigurationIntent()
        )
        
        Group {
            WeatherWidgetEntryView(
                entry: entry
            ).previewContext(
                WidgetPreviewContext(family: .systemSmall)
            )
            
            WeatherWidgetEntryView(
                entry: entry
            ).previewContext(
                WidgetPreviewContext(family: .systemMedium)
            )
            
            WeatherWidgetEntryView(
                entry: entry
            ).previewContext(
                WidgetPreviewContext(family: .systemLarge)
            )
        }
    }
}
