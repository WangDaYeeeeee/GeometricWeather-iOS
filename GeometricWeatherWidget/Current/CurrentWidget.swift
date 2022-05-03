//
//  CurrentWidget.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2022/4/30.
//

import WidgetKit
import SwiftUI
import Intents
import GeometricWeatherBasic

private let elementSize = 56.0
private let elementOffsetX = 10.0
private let elementOffsetY = 15.0

// MARK: - view.

struct CurrentWidgetEntryView : View {
    
    var entry: Provider.Entry

    var body: some View {
        if self.entry.location.weather == nil {
            PlaceholderView()
        } else {
            VStack(alignment: .leading, spacing: 0.0) {
                Spacer()
                
                HStack(alignment: .center, spacing: 0.0) {
                    Spacer()
                    
                    Text(
                        SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                            self.entry.location.weather!.current.temperature.temperature,
                            unit: "º"
                        )
                    ).font(
                        .system(size: elementSize, weight: .regular, design: .default)
                    ).foregroundColor(
                        .white.opacity(0.5)
                    ).offset(
                        x: -elementOffsetX,
                        y: elementOffsetY
                    )
                }
                
                if let icon = UIImage.getWeatherIcon(
                    weatherCode: self.entry.location.weather!.current.weatherCode,
                    daylight: self.entry.location.daylight
                )?.scaleToSize(
                    CGSize(
                        width: elementSize,
                        height: elementSize
                    )
                ) {
                    Image(uiImage: icon).offset(
                        x: elementOffsetX,
                        y: -elementOffsetY
                    )
                    Spacer()
                }
            }.padding()
                .background(
                    ThemeManager.shared.weatherThemeDelegate.getWidgetBackgroundView(
                        weatherKind: weatherCodeToWeatherKind(
                            code: self.entry.location.weather?.current.weatherCode ?? .clear
                        ),
                        daylight: self.entry.location.daylight
                    )
                )
        }
    }
}

// MARK: - widget.

struct CurrentWidget: Widget {
    
    let kind: String = "CurrentWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            CurrentWidgetEntryView(entry: entry)
        }.configurationDisplayName(
            getLocalizedText("live")
        ).supportedFamilies(
            [.systemSmall]
        )
    }
}

// MARK: - preview.

struct CurrentWidget_Previews: PreviewProvider {
        
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
            CurrentWidgetEntryView(
                entry: entry
            ).previewContext(
                WidgetPreviewContext(family: .systemMedium)
            )
        }
    }
}
