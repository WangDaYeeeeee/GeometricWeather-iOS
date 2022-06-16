//
//  DetailsViews.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/6/16.
//

import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings

private let itemVerticalMargin = 8.0
private let itemHorizontalMargin = littleMargin

private let itemEdgeInsets = EdgeInsets(
    top: itemVerticalMargin,
    leading: itemHorizontalMargin,
    bottom: itemVerticalMargin,
    trailing: itemHorizontalMargin
)

// MARK: - section title.

struct DetailsSectionTitleView: View {
    
    let key: String
    
    var body: some View {
        Text(
            getLocalizedText(key)
        ).font(
            Font(bodyFont)
        ).foregroundColor(
            Color(UIColor.secondaryLabel)
        )
    }
}


// MARK: - weather header.

struct DetailsWeatherHeaderView: View {
    
    let weatherCode: WeatherCode
    let daylight: Bool
    
    let weatherText: String
    let temperature: Temperature
    
    var body: some View {
        HStack(alignment: .center, spacing: littleMargin) {
            Image.getWeatherIcon(
                weatherCode: self.weatherCode,
                daylight: self.daylight
            )?.resizable().frame(
                width: 56,
                height: 56
            )
            
            VStack(alignment: .leading, spacing: 2.0) {
                Text(
                    self.weatherText
                    + ", "
                    + SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                        self.temperature.temperature,
                        unit: getLocalizedText(SettingsManager.shared.temperatureUnit.key)
                    )
                ).font(
                    Font(titleFont)
                ).foregroundColor(
                    Color(UIColor.label)
                )
                
                if let apparentTemperature = temperature.apparentTemperature {
                    Text(
                        getLocalizedText("feels_like")
                        + " "
                        + SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                            apparentTemperature,
                            unit: getLocalizedText(SettingsManager.shared.temperatureUnit.key)
                        )
                    ).font(
                        Font(captionFont)
                    ).foregroundColor(
                        Color(UIColor.secondaryLabel)
                    )
                }
            }
        }.padding(itemEdgeInsets)
    }
}

// MARK: - value item.

struct DetailsValueItemView: View {
    
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(
                self.title
            ).font(
                Font(titleFont)
            ).foregroundColor(
                Color(UIColor.label)
            )
            
            Text(
                self.content
            ).font(
                Font(bodyFont)
            ).foregroundColor(
                Color(UIColor.secondaryLabel)
            )
        }.padding(itemEdgeInsets)
    }
}

// MARK: - sun moon item.

struct DetailsSunMoonItemView: View {
    
    let sun: Astro
    let moon: Astro
    let moonPhase: MoonPhase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if self.moonPhase.isValid() {
                Text(
                    getLocalizedText(self.moonPhase.getMoonPhaseKey())
                ).font(
                    Font(titleFont)
                ).foregroundColor(
                    Color(UIColor.label)
                ).padding(itemEdgeInsets)
            }
            
            HStack(alignment: .center, spacing: 0.0) {
                if self.sun.isValid() {
                    Image
                        .getSunIcon()?
                        .resizable()
                        .frame(width: 24.0, height: 24.0)
                        .padding(
                            EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: 0,
                                trailing: itemHorizontalMargin
                            )
                        )

                    Text(
                        self.sun.formateRiseTime(twelveHour: isTwelveHour()) + "↑"
                        + "\n"
                        + self.sun.formateSetTime(twelveHour: isTwelveHour()) + "↓"
                    ).font(
                        Font(bodyFont)
                    ).foregroundColor(
                        Color(UIColor.secondaryLabel)
                    )
                }
                
                Spacer()
                
                if self.moon.isValid() {
                    Text(
                        self.moon.formateRiseTime(twelveHour: isTwelveHour()) + "↑"
                        + "\n"
                        + self.moon.formateSetTime(twelveHour: isTwelveHour()) + "↓"
                    ).font(
                        Font(bodyFont)
                    ).multilineTextAlignment(
                        .trailing
                    ).foregroundColor(
                        Color(UIColor.secondaryLabel)
                    )
                    
                    Image
                        .getMoonIcon()?
                        .resizable()
                        .frame(width: 24.0, height: 24.0)
                        .padding(
                            EdgeInsets(
                                top: 0,
                                leading: itemHorizontalMargin,
                                bottom: 0,
                                trailing: 0
                            )
                        )
                }
            }.padding(itemEdgeInsets)
        }
    }
}

// MARK: - daily air quality item.

struct DetailsAirQualityItemView: View {
    
    let aqi: AirQuality
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let aqi = self.aqi.aqiIndex {
                DetailsProgressView(
                    title: getLocalizedText("air_quality"),
                    description: aqi.description + " / " + getAirQualityText(
                        level: self.aqi.getAqiLevel()
                    ),
                    progress: min(
                        Double(aqi) / Double(aqiIndexLevel5),
                        1.0
                    ),
                    color: getLevelColor(
                        self.aqi.getAqiLevel()
                    )
                )
            }
            
            if let pm25 = aqi.pm25 {
                if pm25 > 0 {
                    DetailsProgressView(
                        title: "PM2.5",
                        description: "\(Int(pm25))μg/m³",
                        progress: min(
                            pm25 / 250.0,
                            1.0
                        ),
                        color: getLevelColor(
                            self.aqi.getPm25Level()
                        )
                    )
                }
            }
            
            if let pm10 = aqi.pm10 {
                if pm10 > 0 {
                    DetailsProgressView(
                        title: "PM10",
                        description: "\(Int(pm10))μg/m³",
                        progress: min(
                            pm10 / 420.0,
                            1.0
                        ),
                        color: getLevelColor(
                            self.aqi.getPm10Level()
                        )
                    )
                }
            }
            
            if let no2 = aqi.no2 {
                if no2 > 0 {
                    DetailsProgressView(
                        title: "NO₂",
                        description: "\(Int(no2))μg/m³",
                        progress: min(
                            no2 / 565.0,
                            1.0
                        ),
                        color: getLevelColor(
                            self.aqi.getNo2Level()
                        )
                    )
                }
            }
            
            if let so2 = aqi.so2 {
                if so2 > 0 {
                    DetailsProgressView(
                        title: "SO₂",
                        description: "\(Int(so2))μg/m³",
                        progress: min(
                            so2 / 1600.0,
                            1.0
                        ),
                        color: getLevelColor(
                            self.aqi.getSo2Level()
                        )
                    )
                }
            }
            
            if let o3 = aqi.o3 {
                if o3 > 0 {
                    DetailsProgressView(
                        title: "O₃",
                        description: "\(Int(o3))μg/m³",
                        progress: min(
                            o3 / 800.0,
                            1.0
                        ),
                        color: getLevelColor(
                            self.aqi.getO3Level()
                        )
                    )
                }
            }
            
            if let co = aqi.co {
                if co > 0 {
                    DetailsProgressView(
                        title: "CO",
                        description: "\(Int(co))mg/m³",
                        progress: min(
                            co / 90.0,
                            1.0
                        ),
                        color: getLevelColor(
                            self.aqi.getCOLevel()
                        )
                    )
                }
            }
        }.padding(
            EdgeInsets(
                top: 0.0,
                leading: itemVerticalMargin,
                bottom: 0.0,
                trailing: itemVerticalMargin
            )
        )
    }
}

// MARK: - daily progress.

struct DetailsProgressView: View {
    
    let title: String
    let description: String
    let progress: Double
    let color: UIColor
    
    private static let strokeWidth = 10.0
    private static let backgroundAlpha = 0.33
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(
                self.title
            ).font(
                Font(titleFont)
            ).foregroundColor(
                Color(UIColor.label)
            )
            
            GeometryReader { proxy in
                ZStack {
                    Path { path in
                        path.move(
                            to: CGPoint(
                                x: Self.strokeWidth,
                                y: proxy.size.height * 0.5
                            )
                        )
                        path.addLine(
                            to: CGPoint(
                                x: proxy.size.width - Self.strokeWidth,
                                y: proxy.size.height * 0.5
                            )
                        )
                    }.stroke(
                        Color(
                            self.color.withAlphaComponent(Self.backgroundAlpha)
                        ),
                        style: StrokeStyle(
                            lineWidth: Self.strokeWidth,
                            lineCap: .round
                        )
                    ).frame(
                        width: proxy.size.width,
                        height: proxy.size.height,
                        alignment: .center
                    )
                    
                    Path { path in
                        path.move(
                            to: CGPoint(
                                x: Self.strokeWidth,
                                y: proxy.size.height * 0.5
                            )
                        )
                        path.addLine(
                            to: CGPoint(
                                x: Self.strokeWidth + (
                                    proxy.size.width - 2 * Self.strokeWidth
                                ) * self.progress,
                                y: proxy.size.height * 0.5
                            )
                        )
                    }.stroke(
                        Color(self.color),
                        style: StrokeStyle(
                            lineWidth: Self.strokeWidth,
                            lineCap: .round
                        )
                    ).shadow(
                        color: Color(self.color),
                        radius: 6.0,
                        x: 0.0,
                        y: 3.0
                    ).frame(
                        width: proxy.size.width,
                        height: proxy.size.height,
                        alignment: .center
                    )
                }
            }
            
            HStack {
                Spacer()
                
                Text(
                    self.description
                ).font(
                    Font(captionFont)
                ).foregroundColor(
                    Color(UIColor.tertiaryLabel)
                )
            }
        }.padding(
            EdgeInsets(
                top: itemVerticalMargin,
                leading: 0.0,
                bottom: itemVerticalMargin,
                trailing: 0.0
            )
        )
    }
}

// MARK: - daily pollen.

struct DetailsPollenView: View {
    
    let pollen: Pollen
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                DetailsDotValueItemView(
                    title: getLocalizedText("grass"),
                    description: (
                        self.pollen.grassIndex?.description ?? "0"
                    ) + "/m³ - " + (
                        self.pollen.grassDescription ?? "?"
                    ),
                    color: getLevelColor(self.pollen.grassLevel ?? 0)
                )
                
                DetailsDotValueItemView(
                    title: getLocalizedText("mold"),
                    description: (
                        self.pollen.moldIndex?.description ?? "0"
                    ) + "/m³ - " + (
                        self.pollen.moldDescription ?? "?"
                    ),
                    color: getLevelColor(self.pollen.moldLevel ?? 0)
                )
            }
            
            HStack(alignment: .center, spacing: 0) {
                DetailsDotValueItemView(
                    title: getLocalizedText("ragweed"),
                    description: (
                        self.pollen.ragweedIndex?.description ?? "0"
                    ) + "/m³ - " + (
                        self.pollen.ragweedDescription ?? "?"
                    ),
                    color: getLevelColor(self.pollen.ragweedLevel ?? 0)
                )
                
                DetailsDotValueItemView(
                    title: getLocalizedText("tree"),
                    description: (
                        self.pollen.treeIndex?.description ?? "0"
                    ) + "/m³ - " + (
                        self.pollen.treeDescription ?? "?"
                    ),
                    color: getLevelColor(self.pollen.treeLevel ?? 0)
                )
            }
        }
    }
}

// MARK: - daily dot value item.

struct DetailsDotValueItemView: View {
    
    let title: String
    let description: String
    let color: UIColor
    
    var body: some View {
        HStack(alignment: .center, spacing: itemHorizontalMargin) {
            Circle().frame(
                width: 10.0,
                height: 10.0,
                alignment: .center
            ).foregroundColor(
                Color(self.color)
            ).shadow(
                color: Color(self.color),
                radius: 4.0,
                x: 0.0,
                y: 2.0
            )
            
            VStack(alignment: .leading, spacing: 2.0) {
                Text(
                    self.title
                ).font(
                    Font(titleFont)
                ).foregroundColor(
                    Color(UIColor.label)
                )
                
                Text(
                    self.description
                ).font(
                    Font(miniCaptionFont)
                ).foregroundColor(
                    Color(UIColor.tertiaryLabel)
                )
            }
            
            Spacer()
        }.padding(
            itemEdgeInsets
        )
    }
}
