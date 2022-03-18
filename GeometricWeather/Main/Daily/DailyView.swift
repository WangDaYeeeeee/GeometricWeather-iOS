//
//  DailyView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/10/27.
//

import SwiftUI
import GeometricWeatherBasic

private let itemVerticalMargin = 8.0
private let itemHorizontalMargin = littleMargin

private let itemEdgeInsets = EdgeInsets(
    top: itemVerticalMargin,
    leading: itemHorizontalMargin,
    bottom: itemVerticalMargin,
    trailing: itemHorizontalMargin
)

// MARK: - daily view.

struct DailyView: View {
    
    let weather: Weather
    let index: Int
    let timezone: TimeZone
    
    var body: some View {
        List {
            Section(
                header: DailySectionTitleView(key: "daytime")
            ) {
                HalfDayHeaderView(
                    halfDay: self.weather.dailyForecasts[index].day,
                    daylight: true
                )
                
                if let realFeelTemp = self.weather.dailyForecasts[index].day.temperature.realFeelTemperature {
                    DailyValueItemView(
                        title: NSLocalizedString("real_feel_temperature", comment: ""),
                        content: SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                            realFeelTemp,
                            unit: NSLocalizedString(
                                SettingsManager.shared.temperatureUnit.key,
                                comment: ""
                            )
                        )
                    )
                }
                if let precipitationTotal = self.weather.dailyForecasts[index].day.precipitationTotal {
                    if precipitationTotal > 0 {
                        DailyValueItemView(
                            title: NSLocalizedString("precipitation", comment: ""),
                            content: SettingsManager.shared.precipitationUnit.formatValueWithUnit(
                                precipitationTotal,
                                unit: NSLocalizedString(
                                    SettingsManager.shared.precipitationUnit.key,
                                    comment: ""
                                )
                            )
                        )
                    }
                }
                if let precipitationIntensity = self.weather.dailyForecasts[index].day.precipitationIntensity {
                    if precipitationIntensity > 0 {
                        DailyValueItemView(
                            title: NSLocalizedString("precipitation_intensity", comment: ""),
                            content: SettingsManager.shared.precipitationIntensityUnit.formatValueWithUnit(
                                precipitationIntensity,
                                unit: NSLocalizedString(
                                    SettingsManager.shared.precipitationIntensityUnit.key,
                                    comment: ""
                                )
                            )
                        )
                    }
                }
                if let precipitationProb = self.weather.dailyForecasts[index].day.precipitationProbability {
                    if precipitationProb > 0 {
                        DailyValueItemView(
                            title: NSLocalizedString("precipitation_probability", comment: ""),
                            content: getPercentText(precipitationProb, decimal: 1)
                        )
                    }
                }
                if let wind = self.weather.dailyForecasts[index].day.wind {
                    DailyValueItemView(
                        title: NSLocalizedString("wind", comment: ""),
                        content: getWindText(
                            wind: wind,
                            unit: SettingsManager.shared.speedUnit
                        )
                    )
                }
            }
            
            Section(
                header: DailySectionTitleView(key: "nighttime")
            ) {
                HalfDayHeaderView(
                    halfDay: self.weather.dailyForecasts[index].night,
                    daylight: false
                )
                
                if let realFeelTemp = self.weather.dailyForecasts[index].night.temperature.realFeelTemperature {
                    DailyValueItemView(
                        title: NSLocalizedString("real_feel_temperature", comment: ""),
                        content: SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                            realFeelTemp,
                            unit: NSLocalizedString(
                                SettingsManager.shared.temperatureUnit.key,
                                comment: ""
                            )
                        )
                    )
                }
                if let precipitationTotal = self.weather.dailyForecasts[index].night.precipitationTotal {
                    if precipitationTotal > 0 {
                        DailyValueItemView(
                            title: NSLocalizedString("precipitation", comment: ""),
                            content: SettingsManager.shared.precipitationUnit.formatValueWithUnit(
                                precipitationTotal,
                                unit: NSLocalizedString(
                                    SettingsManager.shared.precipitationUnit.key,
                                    comment: ""
                                )
                            )
                        )
                    }
                }
                if let precipitationIntensity = self.weather.dailyForecasts[index].night.precipitationIntensity {
                    if precipitationIntensity > 0 {
                        DailyValueItemView(
                            title: NSLocalizedString("precipitation_intensity", comment: ""),
                            content: SettingsManager.shared.precipitationIntensityUnit.formatValueWithUnit(
                                precipitationIntensity,
                                unit: NSLocalizedString(
                                    SettingsManager.shared.precipitationIntensityUnit.key,
                                    comment: ""
                                )
                            )
                        )
                    }
                }
                if let precipitationProb = self.weather.dailyForecasts[index].night.precipitationProbability {
                    if precipitationProb > 0 {
                        DailyValueItemView(
                            title: NSLocalizedString("precipitation_probability", comment: ""),
                            content: getPercentText(precipitationProb, decimal: 1)
                        )
                    }
                }
                if let wind = self.weather.dailyForecasts[index].night.wind {
                    DailyValueItemView(
                        title: NSLocalizedString("wind", comment: ""),
                        content: getWindText(
                            wind: wind,
                            unit: SettingsManager.shared.speedUnit
                        )
                    )
                }
            }
            
            Section(
                header: DailySectionTitleView(key: "daily_overview")
            ) {
                if let precipitationTotal = self.weather.dailyForecasts[index].precipitationTotal {
                    if precipitationTotal > 0 {
                        DailyValueItemView(
                            title: NSLocalizedString("precipitation", comment: ""),
                            content: SettingsManager.shared.precipitationUnit.formatValueWithUnit(
                                precipitationTotal,
                                unit: NSLocalizedString(
                                    SettingsManager.shared.precipitationUnit.key,
                                    comment: ""
                                )
                            )
                        )
                    }
                }
                if let precipitationIntensity = self.weather.dailyForecasts[index].precipitationIntensity {
                    if precipitationIntensity > 0 {
                        DailyValueItemView(
                            title: NSLocalizedString("precipitation_intensity", comment: ""),
                            content: SettingsManager.shared.precipitationIntensityUnit.formatValueWithUnit(
                                precipitationIntensity,
                                unit: NSLocalizedString(
                                    SettingsManager.shared.precipitationIntensityUnit.key,
                                    comment: ""
                                )
                            )
                        )
                    }
                }
                if let precipitationProb = self.weather.dailyForecasts[index].precipitationProbability {
                    if precipitationProb > 0 {
                        DailyValueItemView(
                            title: NSLocalizedString("precipitation_probability", comment: ""),
                            content: getPercentText(precipitationProb, decimal: 1)
                        )
                    }
                }
                if let wind = self.weather.dailyForecasts[index].wind {
                    DailyValueItemView(
                        title: NSLocalizedString("wind", comment: ""),
                        content: getWindText(
                            wind: wind,
                            unit: SettingsManager.shared.speedUnit
                        )
                    )
                }
                
                if self.weather.dailyForecasts[index].airQuality.isValid() {
                    DailyAirQualityItemView(
                        aqi: self.weather.dailyForecasts[index].airQuality
                    )
                }
                
                if self.weather.dailyForecasts[index].pollen.isValid() {
                    DailyPollenView(
                        pollen: self.weather.dailyForecasts[index].pollen
                    )
                }
                
                if self.weather.dailyForecasts[index].sun.isValid()
                    || self.weather.dailyForecasts[index].moon.isValid() {
                    DailySunMoonItemView(
                        sun: self.weather.dailyForecasts[index].sun,
                        moon: self.weather.dailyForecasts[index].moon,
                        moonPhase: self.weather.dailyForecasts[index].moonPhase
                    )
                }
                
                if self.weather.dailyForecasts[index].uv.isValid() {
                    DailyValueItemView(
                        title: NSLocalizedString("uv_index", comment: ""),
                        content: self.weather.dailyForecasts[index].uv.getUVDescription()
                    )
                }
            }
        }.listStyle(
            GroupedListStyle()
        ).background(
            Color.clear
        )
    }
}

// MARK: - section title.

struct DailySectionTitleView: View {
    
    let key: String
    
    var body: some View {
        Text(
            NSLocalizedString(key, comment: "")
        ).font(
            Font(bodyFont)
        ).foregroundColor(
            Color(UIColor.secondaryLabel)
        )
    }
}

// MARK: - half day header.

struct HalfDayHeaderView: View {
    
    let halfDay: HalfDay
    let daylight: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: littleMargin) {
            Image(
                uiImage: UIImage.getWeatherIcon(
                    weatherCode: halfDay.weatherCode,
                    daylight: daylight
                )!.scaleToSize(
                    CGSize(width: 56, height: 56)
                )!
            ).frame(
                width: 56,
                height: 56,
                alignment: .center
            )
            
            Text(
                halfDay.weatherPhase
                + ", "
                + SettingsManager.shared.temperatureUnit.formatValueWithUnit(
                    halfDay.temperature.temperature,
                    unit: NSLocalizedString(
                        SettingsManager.shared.temperatureUnit.key,
                        comment: ""
                    )
                )
            ).font(
                Font(titleFont)
            ).foregroundColor(
                Color(UIColor.label)
            )
        }.padding(itemEdgeInsets)
    }
}

// MARK: - value item.

struct DailyValueItemView: View {
    
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

struct DailySunMoonItemView: View {
    
    let sun: Astro
    let moon: Astro
    let moonPhase: MoonPhase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if self.moonPhase.isValid() {
                Text(
                    NSLocalizedString(self.moonPhase.getMoonPhaseKey(), comment: "")
                ).font(
                    Font(titleFont)
                ).foregroundColor(
                    Color(UIColor.label)
                ).padding(itemEdgeInsets)
            }
            
            HStack(alignment: .center, spacing: 0.0) {
                if self.sun.isValid() {
                    Image(
                        uiImage: UIImage.getSunIcon()!.scaleToSize(
                            CGSize(
                                width: 24.0,
                                height: 24.0
                            )
                        )!
                    ).frame(
                        width: 24.0,
                        height: 24.0,
                        alignment: .center
                    ).padding(
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
                    
                    Image(
                        uiImage: UIImage.getMoonIcon()!.scaleToSize(
                            CGSize(
                                width: 24.0,
                                height: 24.0
                            )
                        )!
                    ).frame(
                        width: 24.0,
                        height: 24.0,
                        alignment: .center
                    ).padding(
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

struct DailyAirQualityItemView: View {
    
    let aqi: AirQuality
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let aqi = self.aqi.aqiIndex {
                DailyProgressView(
                    title: NSLocalizedString("air_quality", comment: ""),
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
                    DailyProgressView(
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
                    DailyProgressView(
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
                    DailyProgressView(
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
                    DailyProgressView(
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
                    DailyProgressView(
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
                    DailyProgressView(
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

struct DailyProgressView: View {
    
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

struct DailyPollenView: View {
    
    let pollen: Pollen
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                DailyDotValueItemView(
                    title: NSLocalizedString("grass", comment: ""),
                    description: (
                        self.pollen.grassIndex?.description ?? "0"
                    ) + "/m³ - " + (
                        self.pollen.grassDescription ?? "?"
                    ),
                    color: getLevelColor(self.pollen.grassLevel ?? 0)
                )
                
                DailyDotValueItemView(
                    title: NSLocalizedString("mold", comment: ""),
                    description: (
                        self.pollen.moldIndex?.description ?? "0"
                    ) + "/m³ - " + (
                        self.pollen.moldDescription ?? "?"
                    ),
                    color: getLevelColor(self.pollen.moldLevel ?? 0)
                )
            }
            
            HStack(alignment: .center, spacing: 0) {
                DailyDotValueItemView(
                    title: NSLocalizedString("ragweed", comment: ""),
                    description: (
                        self.pollen.ragweedIndex?.description ?? "0"
                    ) + "/m³ - " + (
                        self.pollen.ragweedDescription ?? "?"
                    ),
                    color: getLevelColor(self.pollen.ragweedLevel ?? 0)
                )
                
                DailyDotValueItemView(
                    title: NSLocalizedString("tree", comment: ""),
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

struct DailyDotValueItemView: View {
    
    let title: String
    let description: String
    let color: UIColor
    
    var body: some View {
        HStack(alignment: .center, spacing: itemHorizontalMargin) {
            Image(
                uiImage: UIImage(
                    systemName: "circle.fill"
                )!.withTintColor(
                    self.color
                ).scaleToSize(
                    CGSize(
                        width: 12.0,
                        height: 12.0
                    )
                )!
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
