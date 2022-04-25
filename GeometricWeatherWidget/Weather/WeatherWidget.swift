//
//  WeatherWidget.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2021/9/23.
//

import WidgetKit
import SwiftUI
import Intents
import GeometricWeatherBasic

// MARK: - view.

struct WeatherWidgetEntryView : View {
    
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let location = self.entry.location,
            let weather = self.entry.location?.weather {
            Group {
                switch self.family {
                case .systemSmall:
                    WeatherWidgetSmallView(location: location)
                case .systemMedium:
                    WeatherWidgetMediumView(location: location)
                default:
                    WeatherWidgetLargeView(location: location)
                }
            }.background(
                ThemeManager.shared.weatherThemeDelegate.getWidgetBackgroundView(
                    weatherKind: weatherCodeToWeatherKind(
                        code: weather.current.weatherCode
                    ),
                    daylight: location.daylight
                )
            )
        } else {
            PlaceholderView()
        }
    }
}

// MARK: - widget.

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
            getLocalizedText("forecast")
        ).supportedFamilies(
            [.systemSmall, .systemMedium, .systemLarge]
        )
    }
}

// MARK: - preview.

struct WeatherWidget_Previews: PreviewProvider {
        
    static var previews: some View {
        let entry = GeoWidgetEntry(
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
