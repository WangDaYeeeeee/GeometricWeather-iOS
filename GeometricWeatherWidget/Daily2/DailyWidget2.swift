//
//  DailyWidget2.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2021/10/11.
//

import WidgetKit
import SwiftUI
import Intents
import GeometricWeatherBasic

// MARK: - view.

struct DailyWidget2EntryView : View {
    
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            ThemeManager.shared.weatherThemeDelegate.getWidgetBackground(
                weatherKind: weatherCodeToWeatherKind(
                    code: self.entry.location.weather?.current.weatherCode ?? .clear
                ),
                daylight: self.entry.location.daylight,
                currentLocation: self.entry.location.currentPosition
            )
            
            HStack {
                CurrentSquareView(
                    location: self.entry.location
                ).padding(
                    .vertical
                )
                                
                HorizontalDailyView(
                    location: self.entry.location
                )
            }.padding(
                .horizontal
            )
        }
    }
}

// MARK: - widget.

struct DailyWidget2: Widget {
    
    let kind: String = "DailyWidget2"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            DailyWidget2EntryView(entry: entry)
        }.configurationDisplayName(
            NSLocalizedString("daily_overview", comment: "")
        ).supportedFamilies(
            [.systemMedium]
        )
    }
}

// MARK: - preview.

struct DailyWidget2_Previews: PreviewProvider {
        
    static var previews: some View {
        let entry = GeoWidgetEntry(
            location: readLocationWithWeatherCache(),
            date: Date(),
            configuration: ConfigurationIntent()
        )
        
        Group {
            DailyWidget2EntryView(
                entry: entry
            ).previewContext(
                WidgetPreviewContext(family: .systemMedium)
            )
        }
    }
}
