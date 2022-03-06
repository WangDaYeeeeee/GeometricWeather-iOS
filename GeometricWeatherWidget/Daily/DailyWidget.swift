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
        DailyView(
            location: self.entry.location
        ).padding(
            EdgeInsets(
                top: littleMargin,
                leading: littleMargin,
                bottom: littleMargin,
                trailing: littleMargin
            )
        ).background(
            ThemeManager.shared.weatherThemeDelegate.getWidgetBackgroundView(
                weatherKind: weatherCodeToWeatherKind(
                    code: self.entry.location.weather?.current.weatherCode ?? .clear
                ),
                daylight: self.entry.location.daylight
            )
        )
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
            NSLocalizedString("daily_overview", comment: "")
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
