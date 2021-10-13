//
//  ImplementaionMapperView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/18.
//

import SwiftUI

struct MtrlForegroundMapperView: View {
    
    private let weatherKind: WeatherKind
    private let daylight: Bool
    
    private let width: CGFloat
    private let height: CGFloat
    
    private let rotation2D: Double
    private let rotation3D: Double
    
    private let paddingTop: Double
    
    init(
        weatherKind: WeatherKind,
        daylight: Bool,
        width: CGFloat,
        height: CGFloat,
        rotation2D: Double,
        rotation3D: Double,
        paddingTop: Double
    ) {
        self.weatherKind = weatherKind
        self.daylight = daylight
        self.width = width
        self.height = height
        self.rotation2D = rotation2D
        self.rotation3D = rotation3D
        self.paddingTop = paddingTop
    }
    
    @ViewBuilder
    var body: some View {
        if weatherKind == .clear && daylight {
            ClearForegroundView(
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop
            )
        } else if weatherKind == .clear {
            MetroShowerForegroundView(
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .cloud && daylight {
            CloudForegroundView(
                type: .partlyCloudyDay,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop
            )
        } else if weatherKind == .cloud {
            CloudForegroundView(
                type: .partlyCloudyNight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop
            )
        } else if weatherKind == .cloudy && daylight {
            CloudForegroundView(
                type: .cloudyDay,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop
            )
        } else if weatherKind == .cloudy {
            CloudForegroundView(
                type: .cloudyNight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop
            )
        } else if weatherKind == .thunder {
            CloudForegroundView(
                type: .thunder,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop
            )
        } else if weatherKind == .fog {
            CloudForegroundView(
                type: .fog,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop
            )
        } else if weatherKind == .haze {
            CloudForegroundView(
                type: .haze,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D,
                paddingTop: paddingTop
            )
        } else if weatherKind == .lightRainy && daylight {
            RainForegroundView(
                type: .rainyDay,
                level: .light,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .lightRainy {
            RainForegroundView(
                type: .rainyNight,
                level: .light,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .middleRainy && daylight {
            RainForegroundView(
                type: .rainyDay,
                level: .middle,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .middleRainy {
            RainForegroundView(
                type: .rainyNight,
                level: .middle,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .haveyRainy && daylight {
            RainForegroundView(
                type: .rainyDay,
                level: .heavy,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .haveyRainy {
            RainForegroundView(
                type: .rainyNight,
                level: .heavy,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .sleet && daylight {
            RainForegroundView(
                type: .sleetDay,
                level: .light,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .sleet {
            RainForegroundView(
                type: .sleetNight,
                level: .light,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .thunderstorm {
            RainForegroundView(
                type: .thunderstrom,
                level: .heavy,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .snow {
            SnowForegroundView(
                daylight: daylight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .hail {
            HailForegroundView(
                daylight: daylight,
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else if weatherKind == .wind {
            WindForegroundView(
                width: width,
                height: height,
                rotation2D: rotation2D,
                rotation3D: rotation3D
            )
        } else {
            
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
        } else if weatherKind == .cloud && daylight {
            CloudBackgroundView(type: .partlyCloudyDay)
        } else if weatherKind == .cloud {
            CloudBackgroundView(type: .partlyCloudyNight)
        } else if weatherKind == .cloudy && daylight {
            CloudBackgroundView(type: .cloudyDay)
        } else if weatherKind == .cloudy {
            CloudBackgroundView(type: .cloudyNight)
        } else if weatherKind == .thunder {
            CloudBackgroundView(type: .thunder)
        } else if weatherKind == .fog {
            CloudBackgroundView(type: .fog)
        } else if weatherKind == .haze {
            CloudBackgroundView(type: .haze)
        } else if (weatherKind == .lightRainy
                   || weatherKind == .middleRainy
                   || weatherKind == .haveyRainy) && daylight {
            RainBackgroundView(type: .rainyDay)
        } else if weatherKind == .lightRainy
                    || weatherKind == .middleRainy
                    || weatherKind == .haveyRainy {
            RainBackgroundView(type: .rainyNight)
        } else if weatherKind == .sleet && daylight {
            RainBackgroundView(type: .sleetDay)
        } else if weatherKind == .sleet {
            RainBackgroundView(type: .sleetNight)
        } else if weatherKind == .thunderstorm {
            RainBackgroundView(type: .thunderstrom)
        } else if weatherKind == .snow {
            SnowBackgroundView(daylight: daylight)
        } else if weatherKind == .hail {
            HailBackgroundView(daylight: daylight)
        } else if weatherKind == .wind {
            WindBackgroundView()
        } else {
            NullBackgroundView()
        }
    }
}

struct MtrlWidgetBackgroundView: View {
    
    let weatherKind: WeatherKind
    let daylight: Bool
    
    @Environment(\.colorScheme) var colorScheme
    let currentLocation: Bool
    
    @ViewBuilder
    public var body: some View {
        let daylight = self.currentLocation ? (
            self.colorScheme == .light
        ) : self.daylight
        
        if weatherKind == .clear && daylight {
            ClearWidgetBackgroundView()
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
                paddingTop: 0.0
            )
        }.background(
            MtrlBackgroundMapperView(
                weatherKind: .clear,
                daylight: true
            )
        ).ignoresSafeArea()
    }
}
