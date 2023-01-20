//
//  PrecipitationActivityIslandBottomView.swift
//  GeometricWeatherLiveActivityExtension
//
//  Created by 王大爷 on 2023/1/18.
//

import WidgetKit
import SwiftUI
import GeometricWeatherCore
import GeometricWeatherResources
import GeometricWeatherSettings
import GeometricWeatherTheme

private let trendItemWidth = 4.0
private let trendItemMargin = 2.0
private let trendItemMaxHeight = 16.0

// MARK: - bottom view.

struct PrecipitationActivityIslandBottomView: View {
    
    let description: String
    let timezone: TimeZone
    let minutely: Minutely
    let themeColor: Color
    let primaryColor: Color
    let secondaryColor: Color
    
    private var hasPrecipitation: Bool {
        (minutely.precipitationIntensities.max() ?? 0.0) > 0.0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            if !self.description.isEmpty {
                HStack(alignment: .top, spacing: 0.0) {
                    Text(self.description)
                        .font(.caption2)
                        .foregroundColor(self.secondaryColor)
                        .padding(
                            EdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: self.hasPrecipitation ? 8.0 : 0.0,
                                trailing: 0
                            )
                        )
                    Spacer(minLength: 0.0)
                }
            }
            
            if self.hasPrecipitation {
                GeometryReader { proxy in
                    let itemCount = Int(
                        (proxy.size.width + trendItemMargin) / (trendItemWidth + trendItemMargin)
                    )
                    let maxIntensity = max(
                        self.minutely.precipitationIntensities.max() ?? 0.0,
                        1.0
                    )
                    let trendItemBottom = proxy.size.height / 2 + 0.5 * trendItemMaxHeight
                    
                    ForEach(0..<itemCount, id: \.self) { index in
                        PrecipitationActivityTrendItemView(
                            themeColor: self.themeColor,
                            index: index,
                            percent: self.getPrecipitationIntensity(
                                at: index,
                                in: itemCount
                            ) / maxIntensity,
                            trendItemBottom: trendItemBottom
                        )
                    }
                }
                .frame(height: trendItemMaxHeight + trendItemWidth)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 4.0, trailing: 0))
                
                PrecipitationActivityTrendDescriptionView(
                    description: self.description,
                    timezone: self.timezone,
                    beginTime: self.minutely.beginTime,
                    endTime: self.minutely.endTime,
                    themeColor: self.themeColor,
                    primaryColor: self.primaryColor,
                    secondaryColor: self.secondaryColor
                )
            }
        }
    }
    
    private func getPrecipitationIntensity(at index: Int, in total: Int) -> Double {
        return self.minutely.precipitationIntensities.get(
            Int(
                Double(self.minutely.precipitationIntensities.count)
                * Double(index)
                / Double(total)
            )
        ) ?? 0.0
    }
}

// MARK: - trend item view.

struct PrecipitationActivityTrendItemView: View {
    
    let themeColor: Color
    let index: Int
    let percent: Double
    let trendItemBottom: CGFloat
    
    var body: some View {
        let x = 0.5 * trendItemWidth + Double(self.index) * (trendItemWidth + trendItemMargin)
        
        Path { path in
            path.move(to: CGPoint(x: x, y: self.trendItemBottom))
            path.addLine(
                to: CGPoint(
                    x: x,
                    y: self.trendItemBottom
                    - trendItemMaxHeight * self.percent.keepIn(range: 0...1)
                )
            )
        }.stroke(
            self.percent > 0 ? self.themeColor : self.themeColor.opacity(0.0),
            style: StrokeStyle(lineWidth: trendItemWidth, lineCap: .round)
        ).shadow(
            color: self.percent > 0 ? self.themeColor.opacity(0.5) : Color.clear,
            radius: verticalHistogramShadowRadius,
            x: verticalHistogramShadowOffsetX,
            y: verticalHistogramShadowOffsetY
        )
    }
}

// MARK: - trend description view.

struct PrecipitationActivityTrendDescriptionView: View {
    
    let description: String
    let timezone: TimeZone
    let beginTime: TimeInterval
    let endTime: TimeInterval
    let themeColor: Color
    let primaryColor: Color
    let secondaryColor: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 2.0) {
            GeometryReader { proxy in
                Path { path in
                    path.move(
                        to: CGPoint(x: 0, y: proxy.size.height / 2.0)
                    )
                    path.addLine(
                        to: CGPoint(x: proxy.size.width, y: proxy.size.height / 2.0)
                    )
                }.stroke(
                    self.themeColor.opacity(0.5),
                    style: StrokeStyle(
                        lineWidth: 0.5,
                        lineCap: .round,
                        dash: [trendItemWidth, trendItemMargin]
                    )
                )
                
                ForEach(0..<5) { index in
                    Path(
                        UIBezierPath(
                            ovalIn: CGRect(
                                x: (proxy.size.width - trendItemWidth) / 4.0 * Double(index),
                                y: 0,
                                width: trendItemWidth,
                                height: trendItemWidth)
                        ).cgPath
                    )
                    .fill()
                    .foregroundColor(self.themeColor)
                }
            }.frame(height: trendItemWidth)
            
            HStack(alignment:.center) {
                Text(
                    formateTime(
                        timeIntervalSine1970: self.beginTime,
                        twelveHour: isTwelveHour()
                    )
                )
                Spacer()
                Text(
                    formateTime(
                        timeIntervalSine1970: (self.beginTime + self.endTime) / 2.0,
                        twelveHour: isTwelveHour()
                    )
                )
                Spacer()
                Text(
                    formateTime(
                        timeIntervalSine1970: self.endTime,
                        twelveHour: isTwelveHour()
                    )
                )
            }
            .font(.caption2.weight(.bold))
            .foregroundColor(self.primaryColor)
        }
    }
}
