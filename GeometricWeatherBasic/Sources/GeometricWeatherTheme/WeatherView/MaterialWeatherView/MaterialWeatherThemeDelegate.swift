//
//  MaterialWeatherThemeDelegate.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/25.
//

import SwiftUI
import GeometricWeatherCore

private let headerHeightRatio: CGFloat = 0.66

public class MaterialWeatherThemeDelegate: WeatherThemeDelegate {
    
    public typealias WeatherView = MaterialWeatherView
    public typealias WidgetBackgroundView = MtrlWidgetBackgroundView
    
    public func getWeatherView(state: WeatherViewState) -> MaterialWeatherView {
        return MaterialWeatherView(state: state)
    }
    
    public func getWidgetBackgroundView(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> MtrlWidgetBackgroundView {
        return MtrlWidgetBackgroundView(
            weatherKind: weatherKind,
            daylight: daylight
        )
    }
    
    public func getThemeColor(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> Color {
        return getBackgroundColor(
            weatherKind: weatherKind,
            daylight: daylight
        ) * 0.75 + .white * 0.25
    }
    
    private func getBackgroundColor(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> Color {
        switch weatherKind {
        case .null:
            return .clear
            
        case .clear:
            return daylight ? .ColorFromRGB(0xfdbc4c) : .ColorFromRGB(0x141b2c)
            
        case .cloud:
            return daylight ? .ColorFromRGB(0x00a5d9) : .ColorFromRGB(0x222d43)
            
        case .cloudy:
            return daylight ? .ColorFromRGB(0x9DAFC1) : .ColorFromRGB(0x263238)
            
        case .lightRainy, .middleRainy, .haveyRainy:
            return daylight ? .ColorFromRGB(0x4097e7) : .ColorFromRGB(0x264e8f)
            
        case .snow:
            return daylight ? .ColorFromRGB(0x68baff) : .ColorFromRGB(0x1a5b92)
            
        case .sleet:
            return daylight ? .ColorFromRGB(0x68baff) : .ColorFromRGB(0x1a5b92)
            
        case .hail:
            return daylight ? .ColorFromRGB(0x68baff) : .ColorFromRGB(0x1a5b92)
            
        case .fog:
            return daylight ? .ColorFromRGB(0xA3AEC2) : .ColorFromRGB(0x4F5D68)
            
        case .haze:
            return daylight ? .ColorFromRGB(0xE1C899) : .ColorFromRGB(0x9c8f7f)
            
        case .thunder, .thunderstorm:
            return daylight ? .ColorFromRGB(0x9577A0) : .ColorFromRGB(0x231739)

        case .wind:
            return daylight ? .ColorFromRGB(0xC7A779) : .ColorFromRGB(0x958675)
        }
    }
    
    public func getHeaderHeight(_ viewHeight: CGFloat) -> CGFloat {
        return viewHeight * headerHeightRatio
    }
    
    public func getCardBackgroundColor(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> Color {
        return .clear
    }
}
