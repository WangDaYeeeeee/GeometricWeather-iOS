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
        if let location = self.entry.location,
            let weather = self.entry.location?.weather {
            GeometryReader { proxy in
                HStack {
                    CurrentSquareView(location: location)
                        .padding()
                        .frame(
                            width: proxy.size.width * 0.5,
                            alignment: .leading
                        )
                    HorizontalDailyView(location: location)
                        .padding(.trailing)
                        .padding(.vertical, 2.0)
                        .frame(
                            width: proxy.size.width * 0.5,
                            alignment: .trailing
                        )
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

private struct PaddingDailyView: View {
    
    let location: Location
    
    var body: some View {
        HorizontalDailyView(
            location: self.location
        ).padding(
            EdgeInsets(
                top: littleMargin,
                leading: 0,
                bottom: littleMargin,
                trailing: 0
            )
        )
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
            getLocalizedText("daily_overview")
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
