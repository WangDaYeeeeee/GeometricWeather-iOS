//
//  MaterialWeatherThemeDelegate.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/25.
//

import SwiftUI

private let headerHeightRatio: CGFloat = 0.66

public class MaterialWeatherThemeDelegate: WeatherThemeDelegate {
    
    public typealias WeatherView = MaterialWeatherView
    public typealias WidgetBackgroundView = MtrlWidgetBackgroundView
    
    public func getWeatherViewController() -> WeatherViewController<MaterialWeatherView> {
        let state = WeatherViewState(
            weatherKind: .null,
            daylight: isDaylight()
        )
        return WeatherViewController(
            MaterialWeatherView(state: state),
            state: state
        )
    }
    
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
    ) -> UIColor {
        return getBackgroundColor(
            weatherKind: weatherKind,
            daylight: daylight
        ) * 0.75 + .white * 0.25
    }
    
    private func getBackgroundColor(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> UIColor {
        switch weatherKind {
        case .null:
            return UIColor.clear
            
        case .clear:
            return daylight ? .colorFromRGB(0xfdbc4c) : .colorFromRGB(0x141b2c)
            
        case .cloud:
            return daylight ? .colorFromRGB(0x00a5d9) : .colorFromRGB(0x222d43)
            
        case .cloudy:
            return daylight ? .colorFromRGB(0x9DAFC1) : .colorFromRGB(0x263238)
            
        case .lightRainy, .middleRainy, .haveyRainy:
            return daylight ? .colorFromRGB(0x4097e7) : .colorFromRGB(0x264e8f)
            
        case .snow:
            return daylight ? .colorFromRGB(0x68baff) : .colorFromRGB(0x1a5b92)
            
        case .sleet:
            return daylight ? .colorFromRGB(0x68baff) : .colorFromRGB(0x1a5b92)
            
        case .hail:
            return daylight ? .colorFromRGB(0x68baff) : .colorFromRGB(0x1a5b92)
            
        case .fog:
            return daylight ? .colorFromRGB(0xA3AEC2) : .colorFromRGB(0x4F5D68)
            
        case .haze:
            return daylight ? .colorFromRGB(0xE1C899) : .colorFromRGB(0x9c8f7f)
            
        case .thunder, .thunderstorm:
            return daylight ? .colorFromRGB(0x9577A0) : .colorFromRGB(0x231739)

        case .wind:
            return daylight ? .colorFromRGB(0xC7A779) : .colorFromRGB(0x958675)
        }
    }
    
    public func getHeaderHeight(_ viewHeight: CGFloat) -> CGFloat {
        return viewHeight * headerHeightRatio
    }
    
    public func getCardBackgroundColor(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> UIColor {
        return .clear
    }
}
