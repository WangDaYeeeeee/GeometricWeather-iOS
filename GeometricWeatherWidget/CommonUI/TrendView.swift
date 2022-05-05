//
//  TrendView.swift
//  GeometricWeatherWidgetExtension
//
//  Created by 王大爷 on 2022/3/11.
//

import SwiftUI
import WidgetKit
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherTheme

private let polyLineWidth = 4.0

typealias PolylineTrend = (start: Double?, center: Double, end: Double?)

private func getPercent(value: Double, range: (min: Int, max: Int)) -> Double {
    return Double(value - Double(range.min)) / Double(range.max - range.min)
}

private func rtlX(_ x: CGFloat, width: CGFloat, rtl: Bool) -> CGFloat {
    return (rtl ? (1.0 - x) : x) * width
}

private func y(_ y: CGFloat, height: CGFloat) -> CGFloat {
    return height - y * height
}

struct TrendView: View {
    
    let highPolylineTrend: PolylineTrend
    let lowPolylineTrend: PolylineTrend
    let histogramValue: Double?
        
    let highPolylineColor: UIColor
    let lowPolylineColor: UIColor
    let histogramColor: UIColor
        
    let highPolylineDescription: String
    let lowPolylineDescription: String
    let histogramDescription: String
    
    init(
        weather: Weather,
        timezone: TimeZone,
        at index: Int,
        of total: Int,
        in range: (min: Int, max: Int)
    ) {
        self.highPolylineTrend = (
            index == 0
            ? nil
            : getPercent(
                value: Double(weather.dailyForecasts[index].day.temperature.temperature
                              + weather.dailyForecasts[index - 1].day.temperature.temperature) / 2.0,
                range: range
            ),
            getPercent(
                value: Double(weather.dailyForecasts[index].day.temperature.temperature),
                range: range
            ),
            index == total - 1
            ? nil
            : getPercent(
                value: Double(weather.dailyForecasts[index].day.temperature.temperature
                              + weather.dailyForecasts[index + 1].day.temperature.temperature) / 2.0,
                range: range
            )
        )
        self.lowPolylineTrend = (
            index == 0
            ? nil
            : getPercent(
                value: Double(weather.dailyForecasts[index].night.temperature.temperature
                              + weather.dailyForecasts[index - 1].night.temperature.temperature) / 2.0,
                range: range
            ),
            getPercent(
                value: Double(weather.dailyForecasts[index].night.temperature.temperature),
                range: range
            ),
            index == total - 1
            ? nil
            : getPercent(
                value: Double(weather.dailyForecasts[index].night.temperature.temperature
                              + weather.dailyForecasts[index + 1].night.temperature.temperature) / 2.0,
                range: range
            )
        )
        self.histogramValue = nil
        
        let color = ThemeManager.shared.weatherThemeDelegate.getThemeColor(
            weatherKind: weatherCodeToWeatherKind(code: weather.current.weatherCode),
            daylight: weather.isDaylight(timezone: timezone)
        )
        self.highPolylineColor = UIColor(color)
        self.lowPolylineColor = UIColor(color)
        self.histogramColor = UIColor(color)
        
        self.highPolylineDescription = SettingsManager.shared.temperatureUnit.formatValueWithUnit(
            weather.dailyForecasts[index].day.temperature.temperature,
            unit: "°"
        )
        self.lowPolylineDescription = SettingsManager.shared.temperatureUnit.formatValueWithUnit(
            weather.dailyForecasts[index].night.temperature.temperature,
            unit: "°"
        )
        self.histogramDescription = ""
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 4.0) {
            Text(self.highPolylineDescription)
                .font(Font(miniCaptionFont))
                .foregroundColor(.white)
            
            GeometryReader { proxy in
                ZStack {
                    SingleTrendView(
                        polylineTrend: self.highPolylineTrend,
                        polylineColor: self.highPolylineColor
                    )
                    SingleTrendView(
                        polylineTrend: self.lowPolylineTrend,
                        polylineColor: self.lowPolylineColor
                    )
                }
            }
            
            Text(self.lowPolylineDescription)
                .font(Font(miniCaptionFont))
                .foregroundColor(.white)
        }
    }
}

struct SingleTrendView: View {
    
    let polylineTrend: PolylineTrend
    let polylineColor: UIColor
    
    @Environment(\.layoutDirection) var layoutDirection
    
    var body: some View {
        GeometryReader { proxy in
            if self.polylineTrend.start == nil {
                Path { path in
                    path.move(
                        to: CGPoint(
                            x: rtlX(
                                0.5,
                                width: proxy.size.width,
                                rtl: self.layoutDirection == .rightToLeft
                            ),
                            y: y(
                                self.polylineTrend.center,
                                height: proxy.size.height
                            )
                        )
                    )
                    path.addLine(
                        to: CGPoint(
                            x: rtlX(
                                1.0,
                                width: proxy.size.width,
                                rtl: self.layoutDirection == .rightToLeft
                            ),
                            y: y(
                                self.polylineTrend.end!,
                                height: proxy.size.height
                            )
                        )
                    )
                }.stroke(
                    Color(self.polylineColor),
                    style: StrokeStyle(
                        lineWidth: polyLineWidth, lineCap: .round
                    )
                )
            } else if polylineTrend.end == nil {
                Path { path in
                    path.move(
                        to: CGPoint(
                            x: rtlX(
                                0,
                                width: proxy.size.width,
                                rtl: self.layoutDirection == .rightToLeft
                            ),
                            y: y(
                                self.polylineTrend.start!,
                                height: proxy.size.height
                            )
                        )
                    )
                    path.addLine(
                        to: CGPoint(
                            x: rtlX(
                                0.5,
                                width: proxy.size.width,
                                rtl: self.layoutDirection == .rightToLeft
                            ),
                            y: y(
                                self.polylineTrend.center,
                                height: proxy.size.height
                            )
                        )
                    )
                }.stroke(
                    Color(self.polylineColor),
                    style: StrokeStyle(
                        lineWidth: polyLineWidth, lineCap: .round
                    )
                )
            } else {
                Path { path in
                    path.move(
                        to: CGPoint(
                            x: rtlX(
                                0,
                                width: proxy.size.width,
                                rtl: self.layoutDirection == .rightToLeft
                            ),
                            y: y(
                                self.polylineTrend.start!,
                                height: proxy.size.height
                            )
                        )
                    )
                    path.addLine(
                        to: CGPoint(
                            x: rtlX(
                                0.5,
                                width: proxy.size.width,
                                rtl: self.layoutDirection == .rightToLeft
                            ),
                            y: y(
                                self.polylineTrend.center,
                                height: proxy.size.height
                            )
                        )
                    )
                    path.addLine(
                        to: CGPoint(
                            x: rtlX(
                                1.0,
                                width: proxy.size.width,
                                rtl: self.layoutDirection == .rightToLeft
                            ),
                            y: y(
                                self.polylineTrend.end!,
                                height: proxy.size.height
                            )
                        )
                    )
                }.stroke(
                    Color(self.polylineColor),
                    style: StrokeStyle(
                        lineWidth: polyLineWidth, lineCap: .round
                    )
                )
            }
        }
    }
}
