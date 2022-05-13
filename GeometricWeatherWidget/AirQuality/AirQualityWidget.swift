//
//  AirQualityWidget.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/4/30.
//

import WidgetKit
import SwiftUI
import Intents
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherTheme

private let maxLinearProgressCount = 3

private struct LinearAQIItemModel: Identifiable {
    var id = UUID()
    
    let value: UInt
    let total: UInt
    let title: String
    let description: String
    let color: Color
}

// MARK: - view.

private struct AQIWidgetEntryView : View {
    
    let entry: Provider.Entry
    let linearItemModels: [LinearAQIItemModel]
    
    init(entry: Provider.Entry) {
        self.entry = entry
        
        var items = [LinearAQIItemModel]()
        var itemCount = 0
        if let weather = entry.location.weather {
            let aqi = weather.current.airQuality
            if let pm25 = aqi.pm25 {
                if pm25 > 0 && itemCount < maxLinearProgressCount {
                    itemCount += 1
                    items.append(
                        LinearAQIItemModel(
                            value: UInt(pm25),
                            total: UInt(250),
                            title: "PM2.5",
                            description: "\(Int(pm25))μg/m³",
                            color: Color(
                                getLevelColor(aqi.getPm25Level())
                            )
                        )
                    )
                }
            }
            if let pm10 = aqi.pm10 {
                if pm10 > 0 && itemCount < maxLinearProgressCount {
                    itemCount += 1
                    items.append(
                        LinearAQIItemModel(
                            value: UInt(pm10),
                            total: UInt(420),
                            title: "PM10",
                            description: "\(Int(pm10))μg/m³",
                            color: Color(
                                getLevelColor(aqi.getPm10Level())
                            )
                        )
                    )
                }
            }
            if let no2 = aqi.no2 {
                if no2 > 0 && itemCount < maxLinearProgressCount {
                    itemCount += 1
                    items.append(
                        LinearAQIItemModel(
                            value: UInt(no2),
                            total: UInt(565),
                            title: "NO₂",
                            description: "\(Int(no2))μg/m³",
                            color: Color(
                                getLevelColor(aqi.getNo2Level())
                            )
                        )
                    )
                }
            }
            if let so2 = aqi.so2 {
                if so2 > 0 && itemCount < maxLinearProgressCount {
                    itemCount += 1
                    items.append(
                        LinearAQIItemModel(
                            value: UInt(so2),
                            total: UInt(1600),
                            title: "SO₂",
                            description: "\(Int(so2))μg/m³",
                            color: Color(
                                getLevelColor(aqi.getSo2Level())
                            )
                        )
                    )
                }
            }
            if let o3 = aqi.o3 {
                if o3 > 0 && itemCount < maxLinearProgressCount {
                    itemCount += 1
                    items.append(
                        LinearAQIItemModel(
                            value: UInt(o3),
                            total: UInt(800),
                            title: "O₃",
                            description: "\(Int(o3))μg/m³",
                            color: Color(
                                getLevelColor(aqi.getO3Level())
                            )
                        )
                    )
                }
            }
            if let co = aqi.co {
                if co > 0 && itemCount < maxLinearProgressCount {
                    itemCount += 1
                    items.append(
                        LinearAQIItemModel(
                            value: UInt(co),
                            total: UInt(90),
                            title: "CO",
                            description: "\(Int(co))mg/m³",
                            color: Color(
                                getLevelColor(aqi.getCOLevel())
                            )
                        )
                    )
                }
            }
        }
        self.linearItemModels = items
    }

    var body: some View {        
        if self.entry.location.weather == nil {
            PlaceholderView()
        } else {
            GeometryReader { proxy in
                HStack(alignment: .center, spacing: 0) {
                    CircularProgressView(
                        value: UInt(
                            self.entry.location.weather?.current.airQuality.aqiIndex ?? 0
                        ),
                        total: UInt(aqiIndexLevel5),
                        description: getAirQualityText(
                            level: self.entry.location.weather?.current.airQuality.aqiLevel ?? 0
                        ),
                        color: Color(
                            getLevelColor(
                                self.entry.location.weather?.current.airQuality.aqiLevel ?? 0
                            )
                        )
                    ).padding(
                        .all,
                        littleMargin
                    ).frame(
                        width: proxy.size.width / 2.0,
                        height: proxy.size.height
                    )
                    
                    VStack(alignment: .center, spacing: 0.0) {
                        ForEach(self.linearItemModels) { model in
                            Spacer()
                            LinearProgressView(
                                value: model.value,
                                total: model.total,
                                title: model.title,
                                description: model.description,
                                color: model.color
                            )
                        }
                        Spacer()
                    }.padding(
                        [.top, .bottom, .trailing],
                        normalMargin
                    ).frame(
                        width: proxy.size.width / 2.0,
                        height: proxy.size.height
                    )
                }
            }
                .background(
                    ThemeManager.weatherThemeDelegate.getWidgetBackgroundView(
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

struct AQIWidget: Widget {
    
    let kind: String = "AQIWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            AQIWidgetEntryView(entry: entry)
        }.configurationDisplayName(
            getLocalizedText("air_quality")
        ).supportedFamilies(
            [.systemMedium]
        )
    }
}

// MARK: - preview.

struct AQIWidget_Previews: PreviewProvider {
        
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
