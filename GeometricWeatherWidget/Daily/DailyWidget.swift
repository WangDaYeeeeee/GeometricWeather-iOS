//
//  DailyWidget.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2021/10/8.
//

import WidgetKit
import SwiftUI
import Intents
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherTheme

// MARK: - view.

struct DailyWidgetEntryView : View {
    
    var entry: Provider.Entry

    var body: some View {
        if self.entry.location.weather == nil {
            PlaceholderView()
        } else {
            DailyView(location: self.entry.location)
                .padding(littleMargin)
                .background(
                    ThemeManager.shared.weatherThemeDelegate.getWidgetBackgroundView(
                        weatherKind: weatherCodeToWeatherKind(
                            code: self.entry.location.weather?.current.weatherCode ?? .clear
                        ),
                        daylight: self.entry.location.isDaylight
                    )
                )
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
            location: Location.buildDefaultLocation(
                weatherSource: WeatherSource[0],
                residentPosition: false
            ),
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
