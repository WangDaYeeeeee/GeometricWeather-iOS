//
//  WeatherView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/14.
//

import SwiftUI

// MARK: - weather kind.

public enum WeatherKind: CaseIterable {
    case null
    case clear
    case cloud
    case cloudy
    case lightRainy
    case middleRainy
    case haveyRainy
    case snow
    case sleet
    case hail
    case fog
    case haze
    case thunder
    case thunderstorm
    case wind
}

public func weatherCodeToWeatherKind(code: WeatherCode) -> WeatherKind {
    switch code {
    case .clear:
        return .clear

    case .partlyCloudy:
        return .cloud

    case .cloudy:
        return .cloudy

    case .rain(.light):
        return .lightRainy
        
    case .rain(.middle):
        return .middleRainy
        
    case .rain(.heavy):
        return .haveyRainy

    case .snow:
        return .snow

    case .wind:
        return .wind

    case .fog:
        return .fog

    case .haze:
        return .haze

    case .sleet:
        return .sleet

    case .hail:
        return .hail

    case .thunder:
        return .thunder

    case .thunderstorm:
        return .thunderstorm
    }
}

// MARK: - state.

public class WeatherViewState: ObservableObject {
    
    @Published private(set) var weatherKind: WeatherKind
    @Published private(set) var prevWeatherKind = WeatherKind.null
    @Published private(set) var daylight: Bool
    @Published private(set) var prevDaylight = true
    
    @Published public var scrollOffset: CGFloat
    @Published public var drawable: Bool
    @Published public var paddingTop: CGFloat
    @Published public var offsetHorizontal: CGFloat
    
    @Published public var updateWeatherTime = 0.0
    
    public init(
        weatherKind: WeatherKind,
        daylight: Bool,
        scrollOffset: CGFloat = 0.0,
        drawable: Bool = true,
        paddingTop: CGFloat = 0.0,
        offsetHorizontal: CGFloat = 0.0
    ) {
        self.weatherKind = weatherKind
        self.daylight = daylight
        self.scrollOffset = scrollOffset
        self.drawable = drawable
        self.paddingTop = paddingTop
        self.offsetHorizontal = offsetHorizontal
    }
    
    public func update(weatherKind: WeatherKind, daylight: Bool) {
        if self.weatherKind == weatherKind
            && self.daylight == daylight {
            return
        }
        
        self.prevWeatherKind = self.weatherKind
        self.prevDaylight = self.daylight
        
        self.weatherKind = weatherKind
        self.daylight = daylight
        
        self.updateWeatherTime = Date().timeIntervalSince1970
    }
}

// MARK: - weather view.

// an abstract for different weather view impl.
public protocol WeatherView {
    
    var state: WeatherViewState { get }
}

// MARK: - theme delegate.

// inject colors and ui properties depend on weather.
public protocol WeatherThemeDelegate {
    
    associatedtype WeatherView: View
    associatedtype WidgetBackgroundView: View
    
    func getWeatherViewController() -> WeatherViewController<WeatherView>
    
    func getWidgetBackgroundView(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> WidgetBackgroundView
        
    // @return (
    //     main theme color,
    //     color of daytime chart line,
    //     color of nighttime chart line
    // )
    func getThemeColors(
        weatherKind: WeatherKind,
        daylight: Bool,
        lightTheme: Bool
    ) -> (main: UIColor, daytime: UIColor, nighttime: UIColor)
    
    func getHeaderHeight(_ viewHeight: CGFloat) -> CGFloat
}

public struct AnyWeatherThemeDelegate<V: View, W: View>: WeatherThemeDelegate {
    
    // method implementations.
    
    private let getWeatherViewControllerFunc: () -> WeatherViewController<V>
    
    private let getWidgetBackgroundViewFunc: (
        _ weatherKind: WeatherKind,
        _ daylight: Bool
    ) -> W
    
    private let getThemeColorsFunc: (
        _ weatherKind: WeatherKind,
        _ daylight: Bool,
        _ lightTheme: Bool
    ) -> (
        main: UIColor,
        daytime: UIColor,
        nighttime: UIColor
    )
    
    private let getHeaderHeightFunc: (
        _ viewHeight: CGFloat
    ) -> CGFloat
    
    // life cycle.
    
    init<Impl: WeatherThemeDelegate>(
        _ impl: Impl
    ) where Impl.WeatherView == V, Impl.WidgetBackgroundView == W {
        
        self.getWeatherViewControllerFunc = impl.getWeatherViewController
        self.getWidgetBackgroundViewFunc = impl.getWidgetBackgroundView(weatherKind:daylight:)
        self.getThemeColorsFunc = impl.getThemeColors(weatherKind:daylight:lightTheme:)
        self.getHeaderHeightFunc = impl.getHeaderHeight(_:)
    }
    
    // override methods.
    
    public func getWeatherViewController() -> WeatherViewController<V> {
        return self.getWeatherViewControllerFunc()
    }
    
    public func getWidgetBackgroundView(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> W {
        return self.getWidgetBackgroundViewFunc(weatherKind, daylight)
    }
        
    // @return (
    //     main theme color,
    //     color of daytime chart line,
    //     color of nighttime chart line
    // )
    public func getThemeColors(
        weatherKind: WeatherKind,
        daylight: Bool,
        lightTheme: Bool
    ) -> (
        main: UIColor,
        daytime: UIColor,
        nighttime: UIColor
    ) {
        return self.getThemeColorsFunc(weatherKind, daylight, lightTheme)
    }
    
    public func getHeaderHeight(_ viewHeight: CGFloat) -> CGFloat {
        return self.getHeaderHeightFunc(viewHeight)
    }
}
