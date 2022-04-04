//
//  ImplementaionMapperView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/18.
//

import SwiftUI

struct MtrlForegroundMapperView: View {
    
    let weatherKind: WeatherKind
    let daylight: Bool
    
    let width: CGFloat
    let height: CGFloat
    
    let rotation2D: Double
    let rotation3D: Double
    
    let paddingTop: Double
    
    let scrollOffset: CGFloat
    let headerHeight: CGFloat
    
    @ViewBuilder
    var body: some View {
        if weatherKind == .clear && daylight {
            ClearForegroundView(
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .clear {
            MetroShowerForegroundView(
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .cloud {
            CloudForegroundView(
                type: .partlyCloudy,
                daylight: daylight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .cloudy {
            CloudForegroundView(
                type: .cloudy,
                daylight: daylight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .thunder {
            CloudForegroundView(
                type: .thunder,
                daylight: daylight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .fog {
            CloudForegroundView(
                type: .fog,
                daylight: daylight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .haze {
            CloudForegroundView(
                type: .haze,
                daylight: daylight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .lightRainy {
            RainForegroundView(
                type: .rainy,
                daylight: daylight,
                level: .light,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .middleRainy {
            RainForegroundView(
                type: .rainy,
                daylight: daylight,
                level: .middle,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .haveyRainy {
            RainForegroundView(
                type: .rainy,
                daylight: daylight,
                level: .heavy,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .sleet {
            RainForegroundView(
                type: .sleet,
                daylight: daylight,
                level: .light,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .thunderstorm {
            RainForegroundView(
                type: .thunderstrom,
                daylight: daylight,
                level: .heavy,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .snow {
            SnowForegroundView(
                daylight: daylight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .hail {
            HailForegroundView(
                daylight: daylight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else if weatherKind == .wind {
            WindForegroundView(
                daylight: daylight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                scrollOffset: scrollOffset,
                headerHeight: headerHeight
            )
        } else {
            NullForegroundView()
        }
    }
}

struct MtrlBackgroundMapperView: View {
    
    private let weatherKind: WeatherKind
    private let daylight: Bool
    
    init(
        weatherKind: WeatherKind,
        daylight: Bool
    ) {
        self.weatherKind = weatherKind
        self.daylight = daylight
    }
    
    @ViewBuilder
    public var body: some View {
        if weatherKind == .clear && daylight {
            ClearBackgroundView()
        } else if weatherKind == .clear {
            MetroShowerBackgroundView()
        } else if weatherKind == .cloud {
            CloudBackgroundView(type: .partlyCloudy, daylight: daylight)
        } else if weatherKind == .cloudy {
            CloudBackgroundView(type: .cloudy, daylight: daylight)
        } else if weatherKind == .thunder {
            CloudBackgroundView(type: .thunder, daylight: daylight)
        } else if weatherKind == .fog {
            CloudBackgroundView(type: .fog, daylight: daylight)
        } else if weatherKind == .haze {
            CloudBackgroundView(type: .haze, daylight: daylight)
        } else if (
            weatherKind == .lightRainy
            || weatherKind == .middleRainy
            || weatherKind == .haveyRainy
        ) {
            RainBackgroundView(type: .rainy, daylight: daylight)
        } else if weatherKind == .sleet {
            RainBackgroundView(type: .sleet, daylight: daylight)
        } else if weatherKind == .thunderstorm {
            RainBackgroundView(type: .thunderstrom, daylight: daylight)
        } else if weatherKind == .snow {
            SnowBackgroundView(daylight: daylight)
        } else if weatherKind == .hail {
            HailBackgroundView(daylight: daylight)
        } else if weatherKind == .wind {
            WindBackgroundView(daylight: daylight)
        } else {
            NullBackgroundView()
        }
    }
}

public struct MtrlWidgetBackgroundView: View {
    
    let weatherKind: WeatherKind
    let daylight: Bool
    
    @ViewBuilder
    public var body: some View {
        if self.weatherKind == .clear && self.daylight {
            ClearWidgetBackgroundView()
        } else if (
            self.weatherKind == .lightRainy
            || self.weatherKind == .middleRainy
            || self.weatherKind == .haveyRainy
        ) && self.daylight {
            RainDayWidgetBackgroundView()
        } else {
            MtrlBackgroundMapperView(
                weatherKind: self.weatherKind,
                daylight: daylight
            )
        }
    }
}

struct MtrlMapperViews_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            MtrlForegroundMapperView(
                weatherKind: .clear,
                daylight: true,
                width: proxy.size.width,
                height: proxy.size.height,
                rotation2D: 0.0,
                rotation3D: 0.0,
                paddingTop: 0.0,
                scrollOffset: 0,
                headerHeight: 1
            )
        }.background(
            MtrlBackgroundMapperView(
                weatherKind: .clear,
                daylight: true
            )
        ).ignoresSafeArea()
    }
}
