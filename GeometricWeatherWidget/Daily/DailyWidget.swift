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
        if let location = self.entry.location,
            let weather = self.entry.location?.weather {
            DailyView(location: location)
                .padding(littleMargin)
                .background(
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

struct DailyWidget: Widget {
    
    let kind: String = "DailyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            DailyWidgetEntryView(entry: entry)
        }.configurationDisplayName(
            getLocalizedText("daily_overview")
        ).supportedFamilies(
            [.systemMedium]
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
