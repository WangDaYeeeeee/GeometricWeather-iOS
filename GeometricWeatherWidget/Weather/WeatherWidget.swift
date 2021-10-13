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
        ZStack {
            ThemeManager.shared.weatherThemeDelegate.getWidgetBackground(
                weatherKind: weatherCodeToWeatherKind(
                    code: self.entry.location.weather?.current.weatherCode ?? .clear
                ),
                daylight: self.entry.location.daylight,
                currentLocation: self.entry.location.currentPosition
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
            NSLocalizedString("forecast", comment: "")
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
