//
//  WeatherView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/14.
//

import SwiftUI
import GeometricWeatherCore

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
public protocol WeatherView: View {
    
    var state: WeatherViewState { get }
}

// MARK: - theme delegate.

// inject colors and ui properties depend on weather.
public protocol WeatherThemeDelegate {
    
    associatedtype WeatherView: View
    associatedtype WidgetBackgroundView: View
    
    func getWeatherView(state: WeatherViewState) -> WeatherView
    
    func getWidgetBackgroundView(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> WidgetBackgroundView
        
    func getThemeColor(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> Color
    
    func getHeaderHeight(_ viewHeight: CGFloat) -> CGFloat
    
    func getCardBackgroundColor(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> Color
}

public struct AnyWeatherThemeDelegate<V: View, W: View>: WeatherThemeDelegate {
    
    // method implementations.
    
    private let getWeatherViewFunc: (_ state: WeatherViewState) -> V
    
    private let getWidgetBackgroundViewFunc: (
        _ weatherKind: WeatherKind,
        _ daylight: Bool
    ) -> W
    
    private let getThemeColorFunc: (
        _ weatherKind: WeatherKind,
        _ daylight: Bool
    ) -> Color
    
    private let getHeaderHeightFunc: (
        _ viewHeight: CGFloat
    ) -> CGFloat
    
    private let getCardBackgroundColorFunc: (
        _ weatherKind: WeatherKind,
        _ daylight: Bool
    ) -> Color
    
    // life cycle.
    
    init<Impl: WeatherThemeDelegate>(
        _ impl: Impl
    ) where Impl.WeatherView == V, Impl.WidgetBackgroundView == W {
        
        self.getWeatherViewFunc = impl.getWeatherView(state:)
        self.getWidgetBackgroundViewFunc = impl.getWidgetBackgroundView(weatherKind:daylight:)
        self.getThemeColorFunc = impl.getThemeColor(weatherKind:daylight:)
        self.getHeaderHeightFunc = impl.getHeaderHeight(_:)
        self.getCardBackgroundColorFunc = impl.getCardBackgroundColor(weatherKind:daylight:)
    }
    
    // override methods.
    
    public func getWeatherView(state: WeatherViewState) -> V {
        return self.getWeatherViewFunc(state)
    }
    
    public func getWidgetBackgroundView(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> W {
        return self.getWidgetBackgroundViewFunc(weatherKind, daylight)
    }
    
    public func getThemeColor(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> Color {
        return self.getThemeColorFunc(weatherKind, daylight)
    }
    
    public func getHeaderHeight(_ viewHeight: CGFloat) -> CGFloat {
        return self.getHeaderHeightFunc(viewHeight)
    }
    
    public func getCardBackgroundColor(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> Color {
        return self.getCardBackgroundColorFunc(weatherKind, daylight)
    }
}
