//
//  DailyWidget.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2021/10/8.
//

import WidgetKit
import SwiftUI
import Intents
import GeometricWeatherBasic

// MARK: - view.

struct DailyWidgetEntryView : View {
    
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            ThemeManager.shared.weatherThemeDelegate.getWidgetBackground(
                weatherKind: weatherCodeToWeatherKind(
                    code: self.entry.location.weather?.current.weatherCode ?? .clear
                ),
                daylight: self.entry.location.daylight
            )
            
            DailyView(location: self.entry.location)
        }
    }
}

// MARK: - widget.

struct DailyWidget: Widget {
    
    let kind: String = "DailyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            WeatherWidgetEntryView(entry: entry)
        }.configurationDisplayName(
            "Daily"
        ).description(
            "Get daily forecast for a selected location."
        )
    }
}

// MARK: - preview.

struct DailyWidget_Previews: PreviewProvider {
        
    static var previews: some View {
        let entry = GeoWidgetEntry(
            location: readLocationWithWeatherCache(),
            date: Date(),
            configuration: ConfigurationIntent()
        )
        
        Group {
            DailyWidgetEntryView(
                entry: entry
            ).previewContext(
                WidgetPreviewContext(family: .systemMedium)
            )
        }
    }
}
